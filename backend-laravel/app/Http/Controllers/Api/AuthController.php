<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

/**
 * IMPORTANT: none of these methods write to AuditLog. Per BantAI's audit
 * policy, the System Administrator dashboard tracks report-related and
 * administrative actions only — never that a user signed up or logged in.
 * Do not add AuditLogger calls here; see App\Services\AuditLogger.
 */
class AuthController extends Controller
{
    // Public self-signup is limited to the "citizen" role. Staff accounts
    // (barangay/LGU/system roles) are provisioned by an LGU Administrator or
    // System Administrator via AdminController — see that controller.
    public function signup(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => strtolower($data['email']),
            'password' => Hash::make($data['password']),
            'role' => 'citizen',
        ]);

        return response()->json([
            'token' => $user->createToken('mobile')->plainTextToken,
            'user' => $user,
        ], 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', strtolower($data['email']))->where('is_active', true)->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['error' => 'Invalid email or password.'], 401);
        }

        return response()->json([
            'token' => $user->createToken('mobile')->plainTextToken,
            'user' => $user,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['success' => true]);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }

    // One-time bootstrap for the very first System Administrator account —
    // see the README's "Creating the first administrative account" section.
    // Requires SYSTEM_ADMIN_SETUP_KEY and refuses to run once any System
    // Administrator already exists.
    public function bootstrapAdmin(Request $request)
    {
        $setupKey = config('app.system_admin_setup_key');

        if (empty($setupKey)) {
            return response()->json(['error' => 'Bootstrap is disabled. Set SYSTEM_ADMIN_SETUP_KEY in .env to enable it.'], 503);
        }
        if ($request->input('setupKey') !== $setupKey) {
            return response()->json(['error' => 'Invalid setup key.'], 401);
        }
        if (User::where('role', 'system_admin')->exists()) {
            return response()->json(['error' => 'A System Administrator account already exists.'], 403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:12'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => strtolower($data['email']),
            'password' => Hash::make($data['password']),
            'role' => 'system_admin',
        ]);

        return response()->json([
            'token' => $user->createToken('admin-web')->plainTextToken,
            'user' => $user,
        ], 201);
    }
}
