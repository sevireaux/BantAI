<?php

use App\Http\Controllers\Web\LoginController;
use App\Livewire\AuditLogs\Index as AuditLogsIndex;
use App\Livewire\Dashboard;
use App\Livewire\Organizations\Index as OrganizationsIndex;
use App\Livewire\OrphanedReports\Index as OrphanedReportsIndex;
use App\Livewire\Reports\Index as ReportsIndex;
use App\Livewire\Reports\Show as ReportsShow;
use App\Livewire\StaffAccounts\Index as StaffAccountsIndex;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect()->route('admin.login')); // root just points at the admin panel

Route::get('/admin/login', [LoginController::class, 'show'])->name('admin.login');
Route::post('/admin/login', [LoginController::class, 'login'])->name('admin.login.attempt')->middleware('throttle:10,1');
Route::post('/admin/logout', [LoginController::class, 'logout'])->name('admin.logout');

Route::middleware('auth')->prefix('admin')->group(function () {
    Route::get('/dashboard', Dashboard::class)->name('admin.dashboard');
    Route::get('/reports', ReportsIndex::class)->name('admin.reports');
    Route::get('/reports/{reportId}', ReportsShow::class)->name('admin.reports.show');

    Route::middleware('role:lgu_admin,system_admin')->group(function () {
        Route::get('/staff', StaffAccountsIndex::class)->name('admin.staff');
    });

    Route::middleware('role:system_admin')->group(function () {
        Route::get('/organizations', OrganizationsIndex::class)->name('admin.organizations');
        Route::get('/orphaned-reports', OrphanedReportsIndex::class)->name('admin.orphaned-reports');
        Route::get('/audit-logs', AuditLogsIndex::class)->name('admin.audit-logs');
    });
});
