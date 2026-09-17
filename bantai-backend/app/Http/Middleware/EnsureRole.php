<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Route-level role gate. Register the alias 'role' in bootstrap/app.php:
 *   $middleware->alias(['role' => \App\Http\Middleware\EnsureRole::class]);
 * Usage: ->middleware('role:lgu_official,lgu_admin')
 *
 * This checks ROLE only. Jurisdiction (which LGU/barangay a user may act
 * within) is enforced separately by App\Policies\ReportPolicy — both checks
 * are required, per the spec's core access-control principle.
 */
class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user || ! in_array($user->role, $roles, true)) {
            return response()->json(['error' => 'You do not have permission to perform this action.'], 403);
        }

        return $next($request);
    }
}
