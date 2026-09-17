<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Report;
use App\Models\ReportNotification;
use App\Models\ReportPhoto;
use App\Models\User;
use App\Services\AiSeverityServiceInterface;
use App\Services\AuditLogger;
use App\Services\ClusteringService;
use App\Services\PhotoStorageServiceInterface;
use App\Services\ReportIdGenerator;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function __construct(
        private readonly ClusteringService $clustering,
        private readonly PhotoStorageServiceInterface $photoStorage,
        private readonly AiSeverityServiceInterface $aiSeverity,
    ) {}

    // -------------------------------------------------------------------
    // List / read
    // -------------------------------------------------------------------
    public function index(Request $request)
    {
        $query = Report::with(['category', 'subcategory', 'barangay', 'user', 'photos', 'statusHistory'])
            ->visibleTo($request->user());

        foreach (['status', 'severity'] as $field) {
            if ($request->filled($field)) {
                $query->where($field, $request->query($field));
            }
        }
        if ($request->filled('category')) {
            $query->whereHas('category', fn ($q) => $q->where('name', $request->query('category')));
        }
        if ($request->filled('barangay')) {
            $query->whereHas('barangay', fn ($q) => $q->where('name', $request->query('barangay')));
        }
        if ($request->filled('search')) {
            $term = '%'.$request->query('search').'%';
            $query->where(fn ($q) => $q->where('title', 'ilike', $term)->orWhere('description', 'ilike', $term));
        }

        $reports = $query->orderByDesc('created_at')->limit(500)->get();

        return response()->json(['reports' => $reports->map(fn ($r) => $this->serialize($r))]);
    }

    public function show(Request $request, Report $report)
    {
        $this->authorize('view', $report);

        return response()->json(['report' => $this->serialize($report->load(['category', 'subcategory', 'barangay', 'user', 'photos', 'statusHistory']))]);
    }

    // -------------------------------------------------------------------
    // Create — accepts photos, runs AI severity, honors offline idempotency
    // -------------------------------------------------------------------
    public function store(Request $request)
    {
        $data = $request->validate([
            'clientUuid' => ['required', 'uuid'],
            'categoryId' => ['required', 'uuid', 'exists:categories,id'],
            'subcategoryId' => ['nullable', 'uuid', 'exists:subcategories,id'],
            'title' => ['nullable', 'string', 'max:120'],
            'description' => ['required', 'string'],
            'address' => ['nullable', 'string'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
            'lguId' => ['nullable', 'uuid', 'exists:lgus,id'],
            'barangayId' => ['nullable', 'uuid', 'exists:barangays,id'],
            'deviceSubmittedAt' => ['nullable', 'date'],
            'photos' => ['nullable', 'array', 'max:5'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        // Idempotency (spec Section 7): `clientUuid` is generated on-device
        // the moment the citizen taps "Submit" — including while offline via
        // the Flutter app's Drift queue. If this exact report already
        // synced (e.g. a retried sync after a dropped connection), return
        // the original instead of creating a duplicate.
        $existing = Report::where('client_uuid', $data['clientUuid'])->first();
        if ($existing) {
            return response()->json(['report' => $this->serialize($existing->load(['category', 'subcategory', 'barangay', 'photos', 'statusHistory'])), 'deduplicated' => true]);
        }

        if (! empty($data['barangayId'])) {
            $barangay = \App\Models\Barangay::find($data['barangayId']);
            if ($barangay && ! empty($data['lguId']) && $barangay->lgu_id !== $data['lguId']) {
                return response()->json(['error' => 'That barangay does not belong to the selected LGU.'], 422);
            }
            $data['lguId'] = $data['lguId'] ?? $barangay?->lgu_id;
        }

        $category = Category::findOrFail($data['categoryId']);

        return DB::transaction(function () use ($request, $data, $category) {
            $cluster = $this->clustering->findOrCreate($data['categoryId'], $data['subcategoryId'] ?? null, $data['barangayId'] ?? null, (float) $data['lat'], (float) $data['lng']);

            $report = Report::create([
                'id' => ReportIdGenerator::next(),
                'client_uuid' => $data['clientUuid'],
                'user_id' => $request->user()->id,
                'lgu_id' => $data['lguId'] ?? null,
                'barangay_id' => $data['barangayId'] ?? null,
                'category_id' => $data['categoryId'],
                'subcategory_id' => $data['subcategoryId'] ?? null,
                'title' => $data['title'] ?: "{$category->name} issue",
                'description' => $data['description'],
                'address' => $data['address'] ?? null,
                'lat' => $data['lat'],
                'lng' => $data['lng'],
                'status' => 'Pending',
                'severity' => 'Moderate', // placeholder until AI assessment runs below
                'cluster_id' => $cluster->id,
                'device_submitted_at' => $data['deviceSubmittedAt'] ?? null,
            ]);

            $firstPhotoUrl = null;
            foreach ($request->file('photos', []) as $file) {
                $uploaded = $this->photoStorage->upload($file, "bantai/reports/{$report->id}");
                ReportPhoto::create([
                    'report_id' => $report->id,
                    'url' => $uploaded->url,
                    'storage_key' => $uploaded->storageKey,
                    'provider' => $this->photoStorage->providerName(),
                    'kind' => 'evidence',
                    'uploaded_by' => $request->user()->id,
                ]);
                $firstPhotoUrl ??= $uploaded->url;
            }

            // AI-determined severity (replaces community-report-count
            // priority) — assessed once, from the first evidence photo.
            // If no photo was attached, this falls back to "Moderate"
            // pending human review, same as a failed AI call.
            if ($firstPhotoUrl) {
                $assessment = $this->aiSeverity->assess($firstPhotoUrl, $category->name, $data['description']);
                $report->update([
                    'severity' => $assessment->severity,
                    'severity_confidence' => $assessment->confidence,
                    'severity_reasoning' => $assessment->reasoning,
                    'severity_source' => 'ai',
                ]);
            }

            $this->clustering->refresh($cluster);
            $report->update(['similar_report_count' => $cluster->fresh()->report_count]);

            $report->statusHistory()->create(['status' => 'Pending', 'changed_by' => $request->user()->id, 'note' => 'Report submitted']);

            ReportNotification::create([
                'user_id' => $request->user()->id,
                'report_id' => $report->id,
                'type' => 'report_submitted',
                'title' => 'Report submitted',
                'message' => "Your report {$report->id} was submitted and is now Pending review.",
            ]);

            AuditLogger::log($request->user(), 'create_report', 'report', $report->id, [], $request);

            return response()->json(['report' => $this->serialize($report->fresh(['category', 'subcategory', 'barangay', 'photos', 'statusHistory']))], 201);
        });
    }

    // -------------------------------------------------------------------
    // Citizen edit / cancel
    // -------------------------------------------------------------------
    private const EDITABLE = ['Pending', 'Verified'];
    private const CANCELLABLE = ['Pending', 'Verified'];

    public function update(Request $request, Report $report)
    {
        $this->authorize('update', $report);
        if (! in_array($report->status, self::EDITABLE, true)) {
            return response()->json(['error' => "Reports with status \"{$report->status}\" can no longer be edited."], 409);
        }

        $data = $request->validate([
            'description' => ['sometimes', 'string'],
            'address' => ['sometimes', 'nullable', 'string'],
        ]);
        $report->update($data);

        return response()->json(['report' => $this->serialize($report)]);
    }

    public function cancel(Request $request, Report $report)
    {
        $this->authorize('cancel', $report);
        if (! in_array($report->status, self::CANCELLABLE, true)) {
            return response()->json(['error' => "Reports with status \"{$report->status}\" can no longer be cancelled."], 409);
        }

        $report->update(['status' => 'Cancelled', 'cancelled_at' => now()]);
        $report->statusHistory()->create(['status' => 'Cancelled', 'changed_by' => $request->user()->id, 'note' => 'Cancelled by citizen']);
        AuditLogger::log($request->user(), 'cancel_report', 'report', $report->id, [], $request);

        return response()->json(['report' => $this->serialize($report)]);
    }

    // -------------------------------------------------------------------
    // LGU Official / LGU Administrator workflow
    // -------------------------------------------------------------------
    public function verify(Request $request, Report $report)
    {
        $this->authorize('verify', $report);
        if ($report->status !== 'Pending') {
            return response()->json(['error' => "Only Pending reports can be verified. This report is \"{$report->status}\"."], 409);
        }

        $data = $request->validate([
            'outcome' => ['required', 'in:verified,rejected,duplicate'],
            'reason' => ['nullable', 'string'],
            'severityOverride' => ['nullable', 'in:Low,Moderate,High,Critical'],
        ]);

        $newStatus = ['verified' => 'Verified', 'rejected' => 'Rejected', 'duplicate' => 'Duplicate'][$data['outcome']];

        $update = [
            'status' => $newStatus,
            'verified_at' => now(),
            'verified_by' => $request->user()->id,
            'invalid_reason' => $newStatus === 'Verified' ? null : ($data['reason'] ?? null),
        ];

        // An LGU Official may correct the AI's severity call during formal
        // verification — this is the human-in-the-loop check on the AI.
        if (! empty($data['severityOverride'])) {
            $update['severity'] = $data['severityOverride'];
            $update['severity_source'] = 'manual';
            $update['severity_overridden_by'] = $request->user()->id;
        }

        $report->update($update);
        $report->statusHistory()->create(['status' => $newStatus, 'changed_by' => $request->user()->id, 'note' => $data['reason'] ?? null]);

        $this->notifyUser($report->user_id, $report->id, 'status_change', "Report {$newStatus}", $this->verifyMessage($report, $newStatus, $data['reason'] ?? null));
        AuditLogger::log($request->user(), 'verify_report', 'report', $report->id, $data, $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    private function verifyMessage(Report $report, string $status, ?string $reason): string
    {
        if ($status === 'Verified') {
            return "Your report {$report->id} has been verified and is now actionable.";
        }

        return "Your report {$report->id} was marked ".strtolower($status).($reason ? ": {$reason}" : '.');
    }

    private const TRANSITIONS = ['Verified' => 'In Progress', 'In Progress' => 'Resolved'];

    public function updateStatus(Request $request, Report $report)
    {
        $this->authorize('updateStatus', $report);
        $data = $request->validate(['status' => ['required', 'string'], 'note' => ['nullable', 'string']]);

        if ((self::TRANSITIONS[$report->status] ?? null) !== $data['status']) {
            return response()->json(['error' => "Cannot move a report from \"{$report->status}\" to \"{$data['status']}\"."], 409);
        }

        $report->update(['status' => $data['status']]);
        $report->statusHistory()->create(['status' => $data['status'], 'changed_by' => $request->user()->id, 'note' => $data['note'] ?? null]);

        $this->notifyUser($report->user_id, $report->id, 'status_change', 'Report status updated', "Your report {$report->id} is now \"{$data['status']}\".".(($data['note'] ?? null) ? " Note: {$data['note']}" : ''));
        AuditLogger::log($request->user(), 'update_status', 'report', $report->id, $data, $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function resolve(Request $request, Report $report)
    {
        $this->authorize('resolve', $report);
        if ($report->status !== 'In Progress') {
            return response()->json(['error' => "Only \"In Progress\" reports can be resolved. This report is \"{$report->status}\"."], 409);
        }

        $data = $request->validate([
            'resolutionDescription' => ['required', 'string'],
            'photos' => ['required', 'array', 'min:1'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $report->update([
            'status' => 'Resolved',
            'resolution_description' => $data['resolutionDescription'],
            'resolution_date' => now(),
            'resolved_at' => now(),
            'resolved_by' => $request->user()->id,
        ]);

        foreach ($request->file('photos') as $file) {
            $uploaded = $this->photoStorage->upload($file, "bantai/reports/{$report->id}/resolution");
            ReportPhoto::create([
                'report_id' => $report->id,
                'url' => $uploaded->url,
                'storage_key' => $uploaded->storageKey,
                'provider' => $this->photoStorage->providerName(),
                'kind' => 'resolution_after',
                'uploaded_by' => $request->user()->id,
            ]);
        }

        $report->statusHistory()->create(['status' => 'Resolved', 'changed_by' => $request->user()->id, 'note' => $data['resolutionDescription']]);
        $this->notifyFollowers($report, 'resolved', 'Report resolved', "Report {$report->id} has been marked Resolved. Resolution evidence is now available.");
        AuditLogger::log($request->user(), 'resolve_report', 'report', $report->id, [], $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function close(Request $request, Report $report)
    {
        $this->authorize('close', $report);
        if ($report->status !== 'Resolved') {
            return response()->json(['error' => "Only \"Resolved\" reports can be closed. This report is \"{$report->status}\"."], 409);
        }

        $report->update(['status' => 'Closed', 'closed_at' => now(), 'closed_by' => $request->user()->id]);
        $report->statusHistory()->create(['status' => 'Closed', 'changed_by' => $request->user()->id, 'note' => 'Final review complete']);
        $this->notifyFollowers($report, 'closed', 'Report closed', "Report {$report->id} has completed final review and is now part of the historical civic record.");
        AuditLogger::log($request->user(), 'close_report', 'report', $report->id, [], $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    // -------------------------------------------------------------------
    // Community monitoring
    // -------------------------------------------------------------------
    public function confirmSimilar(Request $request, Report $report)
    {
        if (! $report->cluster_id) {
            return response()->json(['error' => 'This report is not linked to an issue cluster.'], 409);
        }

        DB::table('report_confirmations')->insertOrIgnore([
            'id' => (string) \Illuminate\Support\Str::uuid(),
            'report_id' => $report->id,
            'user_id' => $request->user()->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $cluster = $this->clustering->refresh($report->cluster);
        Report::where('cluster_id', $cluster->id)->update(['similar_report_count' => $cluster->report_count]);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function follow(Request $request, Report $report)
    {
        $report->followers()->syncWithoutDetaching([$request->user()->id]);

        return response()->json(['following' => true]);
    }

    public function unfollow(Request $request, Report $report)
    {
        $report->followers()->detach($request->user()->id);

        return response()->json(['following' => false]);
    }

    // -------------------------------------------------------------------
    // Barangay Administration — local validation, endorsement, escalation
    // -------------------------------------------------------------------
    private const BARANGAY_ACTIONABLE = ['Pending', 'Verified', 'In Progress'];

    public function barangayConfirm(Request $request, Report $report)
    {
        $this->authorize('barangayAct', $report);
        if (! in_array($report->status, self::BARANGAY_ACTIONABLE, true)) {
            return response()->json(['error' => "Reports with status \"{$report->status}\" can no longer be locally validated."], 409);
        }

        $data = $request->validate([
            'note' => ['nullable', 'string'],
            'photos' => ['nullable', 'array', 'max:5'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $report->update([
            'barangay_confirmed' => true,
            'barangay_confirmed_at' => now(),
            'barangay_confirmed_by' => $request->user()->id,
            'barangay_note' => $data['note'] ?? null,
        ]);

        foreach ($request->file('photos', []) as $file) {
            $uploaded = $this->photoStorage->upload($file, "bantai/reports/{$report->id}/barangay");
            ReportPhoto::create([
                'report_id' => $report->id, 'url' => $uploaded->url, 'storage_key' => $uploaded->storageKey,
                'provider' => $this->photoStorage->providerName(), 'kind' => 'barangay_evidence', 'uploaded_by' => $request->user()->id,
            ]);
        }

        $this->notifyLguStaff($report->lgu_id, $report->id, 'barangay_confirmed', 'Report confirmed by Barangay', "Barangay Administration locally confirmed report {$report->id}.");
        AuditLogger::log($request->user(), 'barangay_confirm', 'report', $report->id, $data, $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function endorsePriority(Request $request, Report $report)
    {
        $this->authorize('barangayAct', $report);
        if (! in_array($report->status, self::BARANGAY_ACTIONABLE, true)) {
            return response()->json(['error' => "Reports with status \"{$report->status}\" can no longer be endorsed."], 409);
        }

        $data = $request->validate(['justification' => ['required', 'string', 'min:10']]);

        $report->update([
            'priority_endorsed' => true,
            'priority_endorsement_reason' => $data['justification'],
            'priority_endorsed_by' => $request->user()->id,
        ]);

        $this->notifyLguStaff($report->lgu_id, $report->id, 'priority_endorsed', 'Priority endorsement from Barangay', "Barangay Administration endorsed report {$report->id} for higher priority: {$data['justification']}");
        AuditLogger::log($request->user(), 'endorse_priority', 'report', $report->id, $data, $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function requestAttention(Request $request, Report $report)
    {
        $this->authorize('barangayAct', $report);
        if (! in_array($report->status, self::BARANGAY_ACTIONABLE, true)) {
            return response()->json(['error' => "Reports with status \"{$report->status}\" can no longer be escalated."], 409);
        }

        $data = $request->validate([
            'reason' => ['required', 'in:urgent,significant,recurring,access-related,safety-related,long-pending'],
            'detail' => ['nullable', 'string'],
        ]);
        $combined = ($data['detail'] ?? null) ? "{$data['reason']}: {$data['detail']}" : $data['reason'];

        $report->update(['attention_requested' => true, 'attention_requested_reason' => $combined, 'attention_requested_by' => $request->user()->id]);

        $this->notifyLguStaff($report->lgu_id, $report->id, 'attention_requested', 'Barangay requests LGU attention', "Barangay Administration flagged report {$report->id} for LGU attention ({$combined}).");
        AuditLogger::log($request->user(), 'request_attention', 'report', $report->id, $data, $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    public function flagRecurring(Request $request, Report $report)
    {
        $this->authorize('barangayAct', $report);
        $report->update(['recurring_flagged' => true, 'recurring_flagged_by' => $request->user()->id]);
        AuditLogger::log($request->user(), 'flag_recurring', 'report', $report->id, [], $request);

        return response()->json(['report' => $this->serialize($report->fresh())]);
    }

    // -------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------
    private function notifyUser(string $userId, string $reportId, string $type, string $title, string $message): void
    {
        ReportNotification::create([
            'user_id' => $userId,
            'report_id' => $reportId,
            'type' => $type,
            'title' => $title,
            'message' => $message,
        ]);
    }

    private function notifyFollowers(Report $report, string $type, string $title, string $message): void
    {
        $userIds = $report->followers()->pluck('users.id')->push($report->user_id)->unique();
        foreach ($userIds as $userId) {
            $this->notifyUser($userId, $report->id, $type, $title, $message);
        }
    }

    private function notifyLguStaff(?string $lguId, string $reportId, string $type, string $title, string $message): void
    {
        if (! $lguId) {
            return;
        }
        $staffIds = User::where('lgu_id', $lguId)->whereIn('role', ['lgu_official', 'lgu_admin'])->where('is_active', true)->pluck('id');
        foreach ($staffIds as $userId) {
            $this->notifyUser($userId, $reportId, $type, $title, $message);
        }
    }

    private function serialize(Report $report): array
    {
        return [
            'id' => $report->id,
            'title' => $report->title,
            'category' => $report->category?->name,
            'subcategory' => $report->subcategory?->name,
            'description' => $report->description,
            'address' => $report->address,
            'lat' => (float) $report->lat,
            'lng' => (float) $report->lng,
            'status' => $report->status,
            'severity' => $report->severity,
            'severityConfidence' => $report->severity_confidence,
            'severitySource' => $report->severity_source,
            'severityReasoning' => $report->severity_reasoning,
            'similarReportCount' => $report->similar_report_count,
            'submittedDate' => $report->created_at,
            'deviceSubmittedAt' => $report->device_submitted_at,
            'photos' => $report->evidencePhotos->pluck('url')->values(),
            'resolutionPhotos' => $report->resolutionPhotos->pluck('url')->values(),
            'barangayPhotos' => $report->barangayPhotos->pluck('url')->values(),
            'history' => $report->statusHistory->map(fn ($h) => ['status' => $h->status, 'date' => $h->created_at, 'note' => $h->note]),
            'resolutionDescription' => $report->resolution_description,
            'resolutionDate' => $report->resolution_date,
            'barangay' => $report->barangay?->name,
            'reporterName' => $report->user?->name,
            'clusterId' => $report->cluster_id,
            'invalidReason' => $report->invalid_reason,
            'barangayConfirmed' => (bool) $report->barangay_confirmed,
            'barangayNote' => $report->barangay_note,
            'priorityEndorsed' => (bool) $report->priority_endorsed,
            'priorityEndorsementReason' => $report->priority_endorsement_reason,
            'attentionRequested' => (bool) $report->attention_requested,
            'attentionRequestedReason' => $report->attention_requested_reason,
            'recurringFlagged' => (bool) $report->recurring_flagged,
        ];
    }
}
