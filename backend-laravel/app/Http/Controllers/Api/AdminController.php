<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Barangay;
use App\Models\Lgu;
use App\Models\Report;
use App\Models\User;
use App\Services\AuditLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    // Final Account-Creation Structure (spec Section 8):
    //   System Administrator -> LGU Administrator, System Administrator
    //   LGU Administrator    -> Barangay Administrator, LGU Official (own LGU only)
    private const ALLOWED_ASSIGNMENTS = [
        'system_admin' => ['lgu_admin', 'system_admin'],
        'lgu_admin' => ['barangay_admin', 'lgu_official'],
    ];

    // -- LGUs (System Administrator only) --------------------------------
    public function listLgus()
    {
        return response()->json(['lgus' => Lgu::orderBy('name')->get()]);
    }

    public function createLgu(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'region' => ['nullable', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:20', 'unique:lgus,code'],
        ]);
        $lgu = Lgu::create($data);
        AuditLogger::log($request->user(), 'create_lgu', 'lgu', $lgu->id, [], $request);

        return response()->json(['lgu' => $lgu], 201);
    }

    // -- Barangays --------------------------------------------------------
    public function listBarangays(Request $request)
    {
        $lguId = $request->user()->role === 'system_admin' ? $request->query('lguId') : $request->user()->lgu_id;

        return response()->json(['barangays' => Barangay::where('lgu_id', $lguId)->orderBy('name')->get()]);
    }

    public function createBarangay(Request $request)
    {
        $lguId = $request->user()->role === 'system_admin' ? $request->input('lguId') : $request->user()->lgu_id;
        $data = $request->validate(['name' => ['required', 'string', 'max:255']]);

        if (! $lguId) {
            return response()->json(['error' => 'lguId is required.'], 400);
        }

        $barangay = Barangay::create(['lgu_id' => $lguId, 'name' => $data['name']]);
        AuditLogger::log($request->user(), 'create_barangay', 'barangay', $barangay->id, [], $request);

        return response()->json(['barangay' => $barangay], 201);
    }

    // -- Staff users --------------------------------------------------------
    public function listUsers(Request $request)
    {
        $query = User::query();
        if ($request->user()->role !== 'system_admin') {
            $query->where('lgu_id', $request->user()->lgu_id);
        }

        return response()->json(['users' => $query->orderByDesc('created_at')->limit(500)->get()]);
    }

    public function createStaffUser(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', 'string'],
            'lguId' => ['nullable', 'uuid'],
            'barangayId' => ['nullable', 'uuid'],
        ]);

        $allowed = self::ALLOWED_ASSIGNMENTS[$request->user()->role] ?? [];
        if (! in_array($data['role'], $allowed, true)) {
            $message = $request->user()->role === 'system_admin'
                ? 'A System Administrator may only create LGU Administrator or System Administrator accounts. LGU Administrators create Barangay Administrator and LGU Official accounts.'
                : 'As an LGU Administrator, you may only create accounts with role: '.implode(' or ', $allowed).'.';

            return response()->json(['error' => $message], 403);
        }

        $lguId = $request->user()->role === 'system_admin'
            ? ($data['role'] === 'system_admin' ? null : ($data['lguId'] ?? null))
            : $request->user()->lgu_id;

        if ($data['role'] !== 'system_admin' && ! $lguId) {
            return response()->json(['error' => 'lguId is required for this role.'], 400);
        }

        $user = User::create([
            'name' => $data['name'],
            'email' => strtolower($data['email']),
            'password' => Hash::make($data['password']),
            'role' => $data['role'],
            'lgu_id' => $lguId,
            'barangay_id' => $data['role'] === 'barangay_admin' ? ($data['barangayId'] ?? null) : null,
        ]);

        AuditLogger::log($request->user(), 'create_staff_user', 'user', $user->id, ['role' => $data['role']], $request);

        return response()->json(['user' => $user], 201);
    }

    public function updateUserRole(Request $request, User $targetUser)
    {
        $data = $request->validate(['role' => ['required', 'string']]);
        $actor = $request->user();
        $allowed = self::ALLOWED_ASSIGNMENTS[$actor->role] ?? [];

        if ($actor->role !== 'system_admin') {
            if (! in_array($data['role'], $allowed, true)) {
                return response()->json(['error' => 'As an LGU Administrator, you may only assign: '.implode(' or ', $allowed).'.'], 403);
            }
            if ($targetUser->lgu_id !== $actor->lgu_id) {
                return response()->json(['error' => 'You can only manage staff within your own LGU.'], 403);
            }
        } elseif (! in_array($data['role'], $allowed, true)) {
            return response()->json(['error' => 'A System Administrator may only assign LGU Administrator or System Administrator roles. Barangay Administrator and LGU Official roles are managed by that LGU\'s Administrator.'], 403);
        }

        if ($targetUser->role === 'system_admin' && $data['role'] !== 'system_admin') {
            if (User::where('role', 'system_admin')->where('is_active', true)->count() <= 1) {
                return response()->json(['error' => "Cannot remove the last System Administrator's admin role."], 409);
            }
        }

        $targetUser->update(['role' => $data['role']]);
        AuditLogger::log($actor, 'update_user_role', 'user', $targetUser->id, $data, $request);

        return response()->json(['user' => $targetUser->fresh()]);
    }

    public function deactivateUser(Request $request, User $targetUser)
    {
        if ($targetUser->role === 'system_admin' && User::where('role', 'system_admin')->where('is_active', true)->count() <= 1) {
            return response()->json(['error' => 'Cannot deactivate the last active System Administrator.'], 409);
        }

        $targetUser->update(['is_active' => false]);
        AuditLogger::log($request->user(), 'deactivate_user', 'user', $targetUser->id, [], $request);

        return response()->json(['success' => true]);
    }

    public function activateUser(Request $request, User $targetUser)
    {
        $targetUser->update(['is_active' => true]);
        AuditLogger::log($request->user(), 'activate_user', 'user', $targetUser->id, [], $request);

        return response()->json(['success' => true]);
    }

    // -- Audit logs (System Administrator) — report/admin actions only,
    //    never login/signup events. See App\Services\AuditLogger.
    public function listAuditLogs()
    {
        $logs = AuditLog::with('user:id,name,email')->orderByDesc('created_at')->limit(500)->get();

        return response()->json(['auditLogs' => $logs]);
    }

    // -- Orphaned-report repair --------------------------------------------
    public function listOrphanedReports()
    {
        $reports = Report::with('category:id,name')
            ->whereNull('lgu_id')
            ->orderByDesc('created_at')
            ->limit(500)
            ->get(['id', 'title', 'address', 'status', 'category_id', 'created_at']);

        return response()->json(['reports' => $reports]);
    }

    public function assignReportJurisdiction(Request $request, Report $report)
    {
        $data = $request->validate([
            'lguId' => ['required', 'uuid', 'exists:lgus,id'],
            'barangayId' => ['nullable', 'uuid'],
        ]);

        if (! empty($data['barangayId'])) {
            $barangay = Barangay::find($data['barangayId']);
            if (! $barangay || $barangay->lgu_id !== $data['lguId']) {
                return response()->json(['error' => 'That barangay does not belong to the selected LGU.'], 422);
            }
        }

        $report->update(['lgu_id' => $data['lguId'], 'barangay_id' => $data['barangayId'] ?? null]);
        AuditLogger::log($request->user(), 'assign_report_jurisdiction', 'report', $report->id, $data, $request);

        return response()->json(['success' => true]);
    }
}
