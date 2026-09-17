<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * The admin panel uses Laravel's normal session-based 'web' guard — separate
 * from Sanctum, which is only for the mobile app's bearer tokens. A citizen
 * can log into the mobile app while an LGU Administrator is independently
 * logged into this web panel; they don't share a session.
 *
 * Like AuthController (API), this never writes to AuditLog — see that
 * controller's docblock for why.
 */
class LoginController extends Controller
{
    public function show()
    {
        if (Auth::check()) {
            return redirect()->route('admin.dashboard');
        }

        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = \App\Models\User::where('email', strtolower($credentials['email']))->first();

        if (! $user || $user->role === 'citizen') {
            return back()->withErrors(['email' => 'This account cannot access the admin panel.']);
        }
        if (! $user->is_active) {
            return back()->withErrors(['email' => 'This account has been deactivated.']);
        }

        if (! Auth::attempt(['email' => $credentials['email'], 'password' => $credentials['password']], $request->boolean('remember'))) {
            return back()->withErrors(['email' => 'Invalid email or password.']);
        }

        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
