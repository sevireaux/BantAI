<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MapController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PublicController;
use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => response()->json(['status' => 'ok', 'time' => now()->toIso8601String()]));

// -- Public (no auth) ------------------------------------------------------
Route::get('/lgus', [PublicController::class, 'lgus']);
Route::get('/barangays', [PublicController::class, 'barangays']);
Route::get('/categories', [CategoryController::class, 'index']);

// -- Auth -------------------------------------------------------------------
Route::post('/auth/signup', [AuthController::class, 'signup'])->middleware('throttle:20,15');
Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:20,15');
Route::post('/auth/bootstrap-admin', [AuthController::class, 'bootstrapAdmin'])->middleware('throttle:20,15');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::post('/categories', [CategoryController::class, 'store'])->middleware('role:lgu_admin,system_admin');
    Route::post('/categories/subcategories', [CategoryController::class, 'storeSubcategory'])->middleware('role:lgu_admin,system_admin');

    // -- Reports --------------------------------------------------------
    Route::get('/reports', [ReportController::class, 'index']);
    Route::post('/reports', [ReportController::class, 'store'])->middleware('role:citizen');
    Route::get('/reports/{report}', [ReportController::class, 'show']);
    Route::patch('/reports/{report}', [ReportController::class, 'update'])->middleware('role:citizen');
    Route::delete('/reports/{report}', [ReportController::class, 'cancel'])->middleware('role:citizen');

    Route::post('/reports/{report}/confirm', [ReportController::class, 'confirmSimilar']);
    Route::post('/reports/{report}/follow', [ReportController::class, 'follow']);
    Route::delete('/reports/{report}/follow', [ReportController::class, 'unfollow']);

    Route::middleware('role:lgu_official,lgu_admin')->group(function () {
        Route::patch('/reports/{report}/verify', [ReportController::class, 'verify']);
        Route::patch('/reports/{report}/status', [ReportController::class, 'updateStatus']);
        Route::patch('/reports/{report}/resolve', [ReportController::class, 'resolve']);
        Route::patch('/reports/{report}/close', [ReportController::class, 'close']);
    });

    Route::middleware('role:barangay_admin')->group(function () {
        Route::patch('/reports/{report}/barangay-confirm', [ReportController::class, 'barangayConfirm']);
        Route::patch('/reports/{report}/endorse-priority', [ReportController::class, 'endorsePriority']);
        Route::patch('/reports/{report}/request-attention', [ReportController::class, 'requestAttention']);
        Route::patch('/reports/{report}/flag-recurring', [ReportController::class, 'flagRecurring']);
    });

    // -- Notifications ----------------------------------------------------
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'markAllRead']);

    // -- Civic map ----------------------------------------------------------
    Route::get('/map/reports', [MapController::class, 'reports']);
    Route::get('/map/hotspots', [MapController::class, 'hotspots']);

    // -- Dashboard ------------------------------------------------------------
    Route::get('/dashboard/summary', [DashboardController::class, 'summary'])
        ->middleware('role:barangay_admin,lgu_official,lgu_admin,system_admin');

    // -- Admin CMS --------------------------------------------------------------
    Route::prefix('admin')->group(function () {
        Route::middleware('role:system_admin')->group(function () {
            Route::get('/lgus', [AdminController::class, 'listLgus']);
            Route::post('/lgus', [AdminController::class, 'createLgu']);
            Route::get('/audit-logs', [AdminController::class, 'listAuditLogs']);
            Route::get('/orphaned-reports', [AdminController::class, 'listOrphanedReports']);
            Route::patch('/orphaned-reports/{report}/assign', [AdminController::class, 'assignReportJurisdiction']);
        });

        Route::middleware('role:lgu_admin,system_admin')->group(function () {
            Route::get('/barangays', [AdminController::class, 'listBarangays']);
            Route::post('/barangays', [AdminController::class, 'createBarangay']);
            Route::get('/users', [AdminController::class, 'listUsers']);
            Route::post('/users', [AdminController::class, 'createStaffUser']);
            Route::patch('/users/{targetUser}/role', [AdminController::class, 'updateUserRole']);
            Route::patch('/users/{targetUser}/deactivate', [AdminController::class, 'deactivateUser']);
            Route::patch('/users/{targetUser}/activate', [AdminController::class, 'activateUser']);
        });
    });
});
