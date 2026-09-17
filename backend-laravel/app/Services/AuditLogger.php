<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\Request;

/**
 * Per BantAI's audit policy: the System Administrator dashboard tracks
 * report-related and administrative actions ONLY — never that a user
 * signed up or logged in. Call this from report/admin controllers; never
 * from AuthController's login/register/logout methods.
 */
class AuditLogger
{
    public static function log(?User $actor, string $action, ?string $targetType = null, ?string $targetId = null, array $details = [], ?Request $request = null): void
    {
        AuditLog::create([
            'user_id' => $actor?->id,
            'action' => $action,
            'target_type' => $targetType,
            'target_id' => $targetId,
            'details' => $details,
            'ip_address' => $request?->ip(),
        ]);
    }
}
