<?php

namespace App\Services;

use App\Models\IssueCluster;
use App\Models\Report;

/**
 * Report Clustering (spec Section 12) — for a prototype, clustering is
 * based on category/subcategory + geographic proximity. This is now purely
 * for community monitoring / civic-map hotspots ("12 nearby reports of this
 * issue"); it no longer determines severity, which comes from
 * AiSeverityServiceInterface instead — see that interface's docblock.
 */
class ClusteringService
{
    private const RADIUS_METERS = 120;
    private const EARTH_RADIUS_METERS = 6371000;

    public function findOrCreate(?string $categoryId, ?string $subcategoryId, ?string $barangayId, float $lat, float $lng): IssueCluster
    {
        $candidates = IssueCluster::where('category_id', $categoryId)
            ->when($subcategoryId, fn ($q) => $q->where('subcategory_id', $subcategoryId), fn ($q) => $q->whereNull('subcategory_id'))
            ->orderByDesc('updated_at')
            ->limit(200)
            ->get();

        foreach ($candidates as $cluster) {
            if ($this->distanceMeters($lat, $lng, $cluster->center_lat, $cluster->center_lng) <= self::RADIUS_METERS) {
                return $cluster;
            }
        }

        return IssueCluster::create([
            'category_id' => $categoryId,
            'subcategory_id' => $subcategoryId,
            'barangay_id' => $barangayId,
            'center_lat' => $lat,
            'center_lng' => $lng,
            'report_count' => 1,
        ]);
    }

    public function refresh(IssueCluster $cluster): IssueCluster
    {
        $agg = Report::where('cluster_id', $cluster->id)
            ->whereNotIn('status', ['Rejected', 'Duplicate', 'Cancelled'])
            ->selectRaw('COUNT(*) as count, AVG(lat) as avg_lat, AVG(lng) as avg_lng')
            ->first();

        $cluster->update([
            'report_count' => $agg->count ?? 0,
            'center_lat' => $agg->avg_lat ?? $cluster->center_lat,
            'center_lng' => $agg->avg_lng ?? $cluster->center_lng,
        ]);

        return $cluster->fresh();
    }

    private function distanceMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $toRad = fn ($deg) => $deg * M_PI / 180;
        $dLat = $toRad($lat2 - $lat1);
        $dLng = $toRad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos($toRad($lat1)) * cos($toRad($lat2)) * sin($dLng / 2) ** 2;

        return self::EARTH_RADIUS_METERS * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }
}
