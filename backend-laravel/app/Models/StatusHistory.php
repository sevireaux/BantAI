<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class StatusHistory extends Model
{
    use HasUuids;

    protected $fillable = ['report_id', 'status', 'changed_by', 'note'];

    public function report()
    {
        return $this->belongsTo(Report::class);
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
