<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Barangay extends Model
{
    use HasUuids;

    protected $fillable = ['lgu_id', 'name'];

    public function lgu()
    {
        return $this->belongsTo(Lgu::class);
    }
}
