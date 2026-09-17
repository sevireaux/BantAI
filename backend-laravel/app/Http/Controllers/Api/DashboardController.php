<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\IssueCluster;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function summary(Request $request)
    {
        $user = $request->user();
        $base = Report::query();

        if ($user->role === 'barangay_admin') {
            $base->where('barangay_id', $user->barangay_id);
        } elseif (in_array($user->role, ['lgu_official', 'lgu_admin'])) {
            $base->where('lgu_id', $user->lgu_id);
        }
        // system_admin: no scope

        $statusCounts = (clone $base)->select('status', DB::raw('count(*) as count'))->groupBy('status')->get();
        $severityCounts = (clone $base)->select('severity', DB::raw('count(*) as count'))->groupBy('severity')->get();

        $byCategory = (clone $base)->join('categories', 'categories.id', '=', 'reports.category_id')
            ->select('categories.name as category', DB::raw('count(*) as count'))
            ->groupBy('categories.name')->orderByDesc('count')->get();

        $byBarangay = (clone $base)->leftJoin('barangays', 'barangays.id', '=', 'reports.barangay_id')
            ->select('barangays.name as barangay', DB::raw('count(*) as count'))
            ->groupBy('barangays.name')->orderByDesc('count')->get();

        $timings = (clone $base)->selectRaw(
            "AVG(EXTRACT(EPOCH FROM (verified_at - reports.created_at)) / 3600) as avg_verification_hours,
             AVG(EXTRACT(EPOCH FROM (resolved_at - verified_at)) / 3600) as avg_resolution_hours"
        )->first();

        $recent = (clone $base)->orderByDesc('created_at')->limit(10)->get(['id', 'title', 'status', 'severity', 'created_at']);

        $topClusters = IssueCluster::with('category', 'barangay')->orderByDesc('report_count')->limit(5)->get();

        return response()->json([
            'statusCounts' => $statusCounts,
            'severityCounts' => $severityCounts,
            'byCategory' => $byCategory,
            'byBarangay' => $byBarangay,
            'averageVerificationHours' => $timings->avg_verification_hours ? round($timings->avg_verification_hours, 1) : null,
            'averageResolutionHours' => $timings->avg_resolution_hours ? round($timings->avg_resolution_hours, 1) : null,
            'recentReports' => $recent,
            'topRecurringLocations' => $topClusters,
        ]);
    }
}
