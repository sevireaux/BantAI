<div>
    <div class="flex items-center justify-between">
        <div>
            <h1 class="text-2xl font-extrabold text-deep">Staff accounts</h1>
            <p class="mt-1 text-sm text-muted">
                @if (auth()->user()->role === 'system_admin')
                    You create LGU Administrator and System Administrator accounts. Each LGU Administrator creates their own Barangay Administrator and LGU Official accounts.
                @else
                    You create Barangay Administrator and LGU Official accounts for your LGU.
                @endif
            </p>
        </div>
        <button wire:click="$set('showCreate', true)" class="rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white">+ Create account</button>
    </div>

    <div class="mt-6 overflow-x-auto rounded-card border border-border bg-surface">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-border text-left text-xs uppercase tracking-wide text-muted">
                    <th class="px-4 py-3">Name</th>
                    <th class="px-4 py-3">Email</th>
                    <th class="px-4 py-3">Role</th>
                    <th class="px-4 py-3 text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-border">
                @forelse ($users as $u)
                    <tr wire:key="user-{{ $u->id }}" class="{{ $u->is_active ? '' : 'opacity-50' }}">
                        <td class="px-4 py-3 font-medium">{{ $u->name }} @unless($u->is_active) <span class="ml-1 rounded-full bg-border px-2 py-0.5 text-[10px] uppercase">Inactive</span> @endunless</td>
                        <td class="px-4 py-3 text-muted">{{ $u->email }}</td>
                        <td class="px-4 py-3">{{ ucwords(str_replace('_', ' ', $u->role)) }}</td>
                        <td class="px-4 py-3 text-right">
                            @if ($u->id !== auth()->id() && $u->role !== 'citizen')
                                <button wire:click="toggleActive('{{ $u->id }}')" class="rounded-lg border border-border px-3 py-1 text-xs hover:bg-surface-alt">
                                    {{ $u->is_active ? 'Deactivate' : 'Reactivate' }}
                                </button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="4" class="px-4 py-8 text-center text-muted">No staff accounts yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if ($showCreate)
        <div class="fixed inset-0 z-20 flex items-center justify-center bg-black/40 px-4" wire:click.self="$set('showCreate', false)">
            <div class="w-full max-w-md rounded-card border border-border bg-surface p-5">
                <h2 class="text-lg font-bold text-deep">Create staff account</h2>
                <div class="mt-4 space-y-3">
                    <div>
                        <label class="mb-1 block text-sm font-medium">Full name</label>
                        <input type="text" wire:model="name" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium">Work email</label>
                        <input type="email" wire:model="email" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium">Temporary password</label>
                        <input type="text" wire:model="password" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium">Role</label>
                        <select wire:model="role" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                            @foreach ($this->assignableRoles() as $r)
                                <option value="{{ $r }}">{{ ucwords(str_replace('_', ' ', $r)) }}</option>
                            @endforeach
                        </select>
                    </div>
                    @if (auth()->user()->role === 'system_admin' && $role !== 'system_admin')
                        <div>
                            <label class="mb-1 block text-sm font-medium">LGU</label>
                            <select wire:model="lguId" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                                <option value="">Select an LGU</option>
                                @foreach ($lgus as $l)
                                    <option value="{{ $l->id }}">{{ $l->name }}</option>
                                @endforeach
                            </select>
                        </div>
                    @endif
                    @if ($role === 'barangay_admin')
                        <div>
                            <label class="mb-1 block text-sm font-medium">Barangay</label>
                            <select wire:model="barangayId" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                                <option value="">Select a barangay</option>
                                @foreach ($this->barangaysForLgu() as $b)
                                    <option value="{{ $b->id }}">{{ $b->name }}</option>
                                @endforeach
                            </select>
                        </div>
                    @endif

                    @if ($formError)
                        <p class="rounded-lg border border-accent/30 bg-accent/10 px-3 py-2 text-sm text-accent">{{ $formError }}</p>
                    @endif

                    <div class="flex justify-end gap-2 pt-2">
                        <button wire:click="$set('showCreate', false)" class="rounded-lg border border-border px-4 py-2 text-sm">Cancel</button>
                        <button wire:click="create" class="rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white">Create account</button>
                    </div>
                </div>
            </div>
        </div>
    @endif
</div>
