<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * IMPORTANT: per BantAI's audit policy, the System Administrator dashboard
 * tracks report-related and administrative actions only — it must NEVER log
 * that a user signed up or logged in. Enforce this by never calling
 * App\Services\AuditLogger from AuthController; see that controller's
 * comments for details. Do not add login/logout/signup logging here even
 * for debugging — use Laravel's normal application log for that instead.
 */
class AuditLog extends Model
{
    use HasUuids;

    protected $fillable = ['user_id', 'action', 'target_type', 'target_id', 'details', 'ip_address'];

    protected function casts(): array
    {
        return ['details' => 'array'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
