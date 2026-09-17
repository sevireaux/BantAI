<?php

namespace App\Livewire;

use App\Models\IssueCluster;
use App\Models\Report;
use Illuminate\Support\Facades\DB;
use Livewire\Component;

class Dashboard extends Component
{
    public function render()
    {
        $user = auth()->user();
        $base = Report::query();

        if ($user->role === 'barangay_admin') {
            $base->where('barangay_id', $user->barangay_id);
        } elseif (in_array($user->role, ['lgu_official', 'lgu_admin'])) {
            $base->where('lgu_id', $user->lgu_id);
        }

        $statusCounts = (clone $base)->select('status', DB::raw('count(*) as count'))->groupBy('status')->pluck('count', 'status');
        $severityCounts = (clone $base)->select('severity', DB::raw('count(*) as count'))->groupBy('severity')->pluck('count', 'severity');
        $recent = (clone $base)->with('category')->orderByDesc('created_at')->limit(8)->get();
        $topClusters = IssueCluster::with('category', 'barangay')->orderByDesc('report_count')->limit(5)->get();

        return view('livewire.dashboard', compact('statusCounts', 'severityCounts', 'recent', 'topClusters'))
            ->layout('layouts.admin', ['title' => 'Dashboard']);
    }
}
