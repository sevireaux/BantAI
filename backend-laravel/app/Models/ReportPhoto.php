<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class ReportPhoto extends Model
{
    use HasUuids;

    protected $fillable = ['report_id', 'url', 'storage_key', 'provider', 'kind', 'uploaded_by'];

    public function report()
    {
        return $this->belongsTo(Report::class);
    }
}
