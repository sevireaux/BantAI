<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, HasUuids, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'role', 'lgu_id', 'barangay_id', 'is_active',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    public function lgu()
    {
        return $this->belongsTo(Lgu::class);
    }

    public function barangay()
    {
        return $this->belongsTo(Barangay::class);
    }

    public function reports()
    {
        return $this->hasMany(Report::class);
    }

    // -- Role helpers ---------------------------------------------------
    public function isCitizen(): bool
    {
        return $this->role === 'citizen';
    }

    public function isBarangayAdmin(): bool
    {
        return $this->role === 'barangay_admin';
    }

    public function isLguStaff(): bool
    {
        return in_array($this->role, ['lgu_official', 'lgu_admin']);
    }

    public function isSystemAdmin(): bool
    {
        return $this->role === 'system_admin';
    }

    // Final Account-Creation Structure (spec): which roles this user may
    // create/assign. System Admin -> LGU Admin/System Admin only. LGU Admin
    // -> Barangay Admin/LGU Official only, within their own LGU.
    public function assignableRoles(): array
    {
        return match ($this->role) {
            'system_admin' => ['lgu_admin', 'system_admin'],
            'lgu_admin' => ['barangay_admin', 'lgu_official'],
            default => [],
        };
    }
}
