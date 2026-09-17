<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Lgu extends Model
{
    use HasUuids;

    protected $fillable = ['name', 'region', 'code', 'settings'];

    protected function casts(): array
    {
        return ['settings' => 'array'];
    }

    public function barangays()
    {
        return $this->hasMany(Barangay::class);
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }
}
