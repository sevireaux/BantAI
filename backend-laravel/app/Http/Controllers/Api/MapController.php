<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\IssueCluster;
use App\Models\Report;
use Illuminate\Http\Request;

class MapController extends Controller
{
    public function reports(Request $request)
    {
        $query = Report::with('category', 'subcategory', 'barangay')
            ->whereNotIn('status', ['Cancelled', 'Rejected', 'Duplicate']);

        if ($request->filled('category')) {
            $query->whereHas('category', fn ($q) => $q->where('name', $request->query('category')));
        }
        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }
        if ($request->filled('barangay')) {
            $query->whereHas('barangay', fn ($q) => $q->where('name', $request->query('barangay')));
        }

        $pins = $query->orderByDesc('created_at')->limit(1000)->get()->map(fn ($r) => [
            'id' => $r->id,
            'title' => $r->title,
            'lat' => (float) $r->lat,
            'lng' => (float) $r->lng,
            'status' => $r->status,
            'severity' => $r->severity,
            'category' => $r->category?->name,
            'subcategory' => $r->subcategory?->name,
            'barangay' => $r->barangay?->name,
            'clusterId' => $r->cluster_id,
        ]);

        return response()->json(['pins' => $pins]);
    }

    public function hotspots()
    {
        $hotspots = IssueCluster::with('category', 'barangay')
            ->where('report_count', '>', 0)
            ->orderByDesc('report_count')
            ->limit(200)
            ->get()
            ->map(fn ($c) => [
                'id' => $c->id,
                'centerLat' => $c->center_lat,
                'centerLng' => $c->center_lng,
                'reportCount' => $c->report_count,
                'category' => $c->category?->name,
                'barangay' => $c->barangay?->name,
            ]);

        return response()->json(['hotspots' => $hotspots]);
    }
}
