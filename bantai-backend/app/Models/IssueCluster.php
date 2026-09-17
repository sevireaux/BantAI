<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class IssueCluster extends Model
{
    use HasUuids;

    protected $fillable = ['category_id', 'subcategory_id', 'barangay_id', 'center_lat', 'center_lng', 'report_count'];

    protected function casts(): array
    {
        return ['center_lat' => 'float', 'center_lng' => 'float'];
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'cluster_id');
    }
}
