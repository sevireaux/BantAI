<?php

namespace App\Livewire\OrphanedReports;

use App\Models\Barangay;
use App\Models\Lgu;
use App\Models\Report;
use App\Services\AuditLogger;
use Livewire\Component;

class Index extends Component
{
    public array $lguChoice = [];
    public array $barangayChoice = [];

    public function barangaysFor(string $reportId): array
    {
        $lguId = $this->lguChoice[$reportId] ?? null;
        if (! $lguId) {
            return [];
        }

        return Barangay::where('lgu_id', $lguId)->orderBy('name')->get()->all();
    }

    public function assign(string $reportId): void
    {
        $lguId = $this->lguChoice[$reportId] ?? null;
        if (! $lguId) {
            return;
        }

        $report = Report::findOrFail($reportId);
        $report->update(['lgu_id' => $lguId, 'barangay_id' => $this->barangayChoice[$reportId] ?? null]);

        AuditLogger::log(auth()->user(), 'assign_report_jurisdiction', 'report', $report->id, ['lguId' => $lguId], request());

        session()->flash('status', "Report {$reportId} assigned.");
    }

    public function render()
    {
        $reports = Report::with('category')->whereNull('lgu_id')->orderByDesc('created_at')->limit(200)->get();
        $lgus = Lgu::orderBy('name')->get();

        return view('livewire.orphaned-reports.index', compact('reports', 'lgus'))
            ->layout('layouts.admin', ['title' => 'Orphaned Reports']);
    }
}
