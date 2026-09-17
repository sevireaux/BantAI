<?php

namespace App\Livewire\StaffAccounts;

use App\Models\Barangay;
use App\Models\Lgu;
use App\Models\User;
use App\Services\AuditLogger;
use Illuminate\Support\Facades\Hash;
use Livewire\Component;

class Index extends Component
{
    private const ALLOWED_ASSIGNMENTS = [
        'system_admin' => ['lgu_admin', 'system_admin'],
        'lgu_admin' => ['barangay_admin', 'lgu_official'],
    ];

    public bool $showCreate = false;
    public string $name = '';
    public string $email = '';
    public string $password = '';
    public string $role = '';
    public ?string $lguId = null;
    public ?string $barangayId = null;
    public string $formError = '';

    public function mount(): void
    {
        $this->role = self::ALLOWED_ASSIGNMENTS[auth()->user()->role][0] ?? '';
    }

    public function assignableRoles(): array
    {
        return self::ALLOWED_ASSIGNMENTS[auth()->user()->role] ?? [];
    }

    public function barangaysForLgu(): array
    {
        if (! $this->lguId) {
            return [];
        }

        return Barangay::where('lgu_id', $this->lguId)->orderBy('name')->get()->all();
    }

    public function create(): void
    {
        $this->formError = '';
        $actor = auth()->user();
        $allowed = $this->assignableRoles();

        if (! in_array($this->role, $allowed, true)) {
            $this->formError = 'You are not permitted to assign that role.';

            return;
        }
        if (strlen($this->password) < 8 || $this->name === '' || $this->email === '') {
            $this->formError = 'Name, email, and a password of at least 8 characters are required.';

            return;
        }

        $lguId = $actor->role === 'system_admin' ? ($this->role === 'system_admin' ? null : $this->lguId) : $actor->lgu_id;
        if ($this->role !== 'system_admin' && ! $lguId) {
            $this->formError = 'Select an LGU.';

            return;
        }

        $user = User::create([
            'name' => $this->name,
            'email' => strtolower($this->email),
            'password' => Hash::make($this->password),
            'role' => $this->role,
            'lgu_id' => $lguId,
            'barangay_id' => $this->role === 'barangay_admin' ? $this->barangayId : null,
        ]);

        AuditLogger::log($actor, 'create_staff_user', 'user', $user->id, ['role' => $this->role], request());

        $this->reset(['name', 'email', 'password', 'lguId', 'barangayId', 'showCreate']);
        session()->flash('status', 'Account created.');
    }

    public function toggleActive(string $userId): void
    {
        $target = User::findOrFail($userId);
        $target->update(['is_active' => ! $target->is_active]);
        AuditLogger::log(auth()->user(), $target->is_active ? 'activate_user' : 'deactivate_user', 'user', $target->id, [], request());
    }

    public function render()
    {
        $actor = auth()->user();
        $users = $actor->role === 'system_admin'
            ? User::orderByDesc('created_at')->limit(500)->get()
            : User::where('lgu_id', $actor->lgu_id)->orderByDesc('created_at')->limit(500)->get();

        $lgus = Lgu::orderBy('name')->get();

        return view('livewire.staff-accounts.index', compact('users', 'lgus'))
            ->layout('layouts.admin', ['title' => 'Staff Accounts']);
    }
}
