<?php

namespace App\Livewire\Reports;

use App\Models\Report;
use App\Models\ReportPhoto;
use App\Services\AuditLogger;
use App\Services\PhotoStorageServiceInterface;
use Illuminate\Support\Facades\Gate;
use Livewire\Component;
use Livewire\WithFileUploads;

class Show extends Component
{
    use WithFileUploads;

    public Report $report;

    public string $verifyNote = '';
    public string $resolveDescription = '';
    /** @var \Livewire\Features\SupportFileUploads\TemporaryUploadedFile[] */
    public array $resolvePhotos = [];

    public string $barangayNote = '';
    public string $justification = '';
    public string $attentionReason = 'urgent';
    public string $attentionDetail = '';

    public function mount(string $reportId): void
    {
        $this->report = Report::with(['category', 'subcategory', 'barangay', 'user', 'photos', 'statusHistory'])->findOrFail($reportId);
        Gate::authorize('view', $this->report);
    }

    private function refresh(): void
    {
        $this->report->refresh();
        $this->report->load(['photos', 'statusHistory']);
    }

    public function verify(string $outcome): void
    {
        Gate::authorize('verify', $this->report);
        abort_unless($this->report->status === 'Pending', 409);

        $this->report->update([
            'status' => ucfirst($outcome === 'verified' ? 'Verified' : $outcome),
            'verified_at' => now(),
            'verified_by' => auth()->id(),
            'invalid_reason' => $outcome === 'verified' ? null : $this->verifyNote,
        ]);
        $this->report->statusHistory()->create(['status' => $this->report->status, 'changed_by' => auth()->id(), 'note' => $this->verifyNote ?: null]);
        AuditLogger::log(auth()->user(), 'verify_report', 'report', $this->report->id, ['outcome' => $outcome], request());

        $this->refresh();
        session()->flash('status', 'Report ' . strtolower($this->report->status) . '.');
    }

    public function markInProgress(): void
    {
        Gate::authorize('updateStatus', $this->report);
        abort_unless($this->report->status === 'Verified', 409);

        $this->report->update(['status' => 'In Progress']);
        $this->report->statusHistory()->create(['status' => 'In Progress', 'changed_by' => auth()->id()]);
        AuditLogger::log(auth()->user(), 'update_status', 'report', $this->report->id, ['status' => 'In Progress'], request());

        $this->refresh();
    }

    public function resolve(PhotoStorageServiceInterface $storage): void
    {
        Gate::authorize('resolve', $this->report);
        abort_unless($this->report->status === 'In Progress', 409);
        $this->validate([
            'resolveDescription' => ['required', 'string'],
            'resolvePhotos' => ['required', 'array', 'min:1'],
        ]);

        $this->report->update([
            'status' => 'Resolved',
            'resolution_description' => $this->resolveDescription,
            'resolution_date' => now(),
            'resolved_at' => now(),
            'resolved_by' => auth()->id(),
        ]);

        foreach ($this->resolvePhotos as $photo) {
            $uploaded = $storage->upload($photo, "bantai/reports/{$this->report->id}/resolution");
            ReportPhoto::create([
                'report_id' => $this->report->id, 'url' => $uploaded->url, 'storage_key' => $uploaded->storageKey,
                'provider' => $storage->providerName(), 'kind' => 'resolution_after', 'uploaded_by' => auth()->id(),
            ]);
        }

        $this->report->statusHistory()->create(['status' => 'Resolved', 'changed_by' => auth()->id(), 'note' => $this->resolveDescription]);
        AuditLogger::log(auth()->user(), 'resolve_report', 'report', $this->report->id, [], request());

        $this->resolveDescription = '';
        $this->resolvePhotos = [];
        $this->refresh();
    }

    public function close(): void
    {
        Gate::authorize('close', $this->report);
        abort_unless($this->report->status === 'Resolved', 409);

        $this->report->update(['status' => 'Closed', 'closed_at' => now(), 'closed_by' => auth()->id()]);
        $this->report->statusHistory()->create(['status' => 'Closed', 'changed_by' => auth()->id(), 'note' => 'Final review complete']);
        AuditLogger::log(auth()->user(), 'close_report', 'report', $this->report->id, [], request());

        $this->refresh();
    }

    public function barangayConfirm(): void
    {
        Gate::authorize('barangayAct', $this->report);

        $this->report->update([
            'barangay_confirmed' => true,
            'barangay_confirmed_at' => now(),
            'barangay_confirmed_by' => auth()->id(),
            'barangay_note' => $this->barangayNote ?: null,
        ]);
        AuditLogger::log(auth()->user(), 'barangay_confirm', 'report', $this->report->id, [], request());

        $this->refresh();
        session()->flash('status', 'Confirmed locally.');
    }

    public function endorsePriority(): void
    {
        Gate::authorize('barangayAct', $this->report);
        $this->validate(['justification' => ['required', 'string', 'min:10']]);

        $this->report->update([
            'priority_endorsed' => true,
            'priority_endorsement_reason' => $this->justification,
            'priority_endorsed_by' => auth()->id(),
        ]);
        AuditLogger::log(auth()->user(), 'endorse_priority', 'report', $this->report->id, [], request());

        $this->justification = '';
        $this->refresh();
        session()->flash('status', 'Priority endorsement submitted.');
    }

    public function requestAttention(): void
    {
        Gate::authorize('barangayAct', $this->report);
        $combined = $this->attentionDetail ? "{$this->attentionReason}: {$this->attentionDetail}" : $this->attentionReason;

        $this->report->update(['attention_requested' => true, 'attention_requested_reason' => $combined, 'attention_requested_by' => auth()->id()]);
        AuditLogger::log(auth()->user(), 'request_attention', 'report', $this->report->id, [], request());

        $this->attentionDetail = '';
        $this->refresh();
        session()->flash('status', 'LGU attention requested.');
    }

    public function flagRecurring(): void
    {
        Gate::authorize('barangayAct', $this->report);
        $this->report->update(['recurring_flagged' => true, 'recurring_flagged_by' => auth()->id()]);
        AuditLogger::log(auth()->user(), 'flag_recurring', 'report', $this->report->id, [], request());

        $this->refresh();
        session()->flash('status', 'Flagged as recurring.');
    }

    public function render()
    {
        return view('livewire.reports.show')->layout('layouts.admin', ['title' => $this->report->id]);
    }
}
