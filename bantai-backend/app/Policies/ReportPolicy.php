<?php

namespace App\Policies;

use App\Models\Report;
use App\Models\User;

/**
 * Core access-control principle: role determines what a user is allowed to
 * DO (checked by which policy method is called / route middleware); this
 * class additionally enforces jurisdiction — what data the user is allowed
 * to access — on every method. A System Administrator always passes; a
 * citizen only for their own report; a Barangay Administrator only within
 * their own barangay; LGU staff only within their own LGU.
 */
class ReportPolicy
{
    public function view(User $user, Report $report): bool
    {
        return $this->inJurisdiction($user, $report);
    }

    public function update(User $user, Report $report): bool
    {
        // Citizen editing their own eligible report.
        return $user->isCitizen() && $report->user_id === $user->id;
    }

    public function cancel(User $user, Report $report): bool
    {
        return $user->isCitizen() && $report->user_id === $user->id;
    }

    public function verify(User $user, Report $report): bool
    {
        return $user->isLguStaff() && $this->inJurisdiction($user, $report);
    }

    public function updateStatus(User $user, Report $report): bool
    {
        return $user->isLguStaff() && $this->inJurisdiction($user, $report);
    }

    public function resolve(User $user, Report $report): bool
    {
        return $user->isLguStaff() && $this->inJurisdiction($user, $report);
    }

    public function close(User $user, Report $report): bool
    {
        return $user->isLguStaff() && $this->inJurisdiction($user, $report);
    }

    // Barangay Administration — local validation / endorsement / escalation.
    public function barangayAct(User $user, Report $report): bool
    {
        return $user->isBarangayAdmin() && $report->barangay_id === $user->barangay_id;
    }

    private function inJurisdiction(User $user, Report $report): bool
    {
        return match ($user->role) {
            'system_admin' => true,
            'citizen' => $report->user_id === $user->id,
            'barangay_admin' => $report->barangay_id === $user->barangay_id,
            'lgu_official', 'lgu_admin' => $report->lgu_id === $user->lgu_id,
            default => false,
        };
    }
}
