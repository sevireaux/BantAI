<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class ReportNotification extends Model
{
    use HasUuids;

    protected $table = 'notifications';

    protected $fillable = ['user_id', 'report_id', 'type', 'title', 'message', 'read'];

    protected function casts(): array
    {
        return ['read' => 'boolean'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function report()
    {
        return $this->belongsTo(Report::class);
    }
}
