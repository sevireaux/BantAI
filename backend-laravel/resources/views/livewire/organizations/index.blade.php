<div>
    <h1 class="text-2xl font-extrabold text-deep">LGUs &amp; Barangays</h1>
    <p class="mt-1 text-sm text-muted">Register each participating LGU, then its barangays, before assigning staff.</p>

    <div class="mt-6 grid gap-6 lg:grid-cols-2">
        <div class="rounded-card border border-border bg-surface p-5">
            <h2 class="text-xs font-semibold uppercase tracking-wide text-muted">Register an LGU</h2>
            <div class="mt-3 space-y-2">
                <input type="text" wire:model="lguName" placeholder="LGU name" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                <input type="text" wire:model="lguRegion" placeholder="Region (optional)" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                <input type="text" wire:model="lguCode" placeholder="Short code, e.g. QC" class="w-full rounded-lg border border-border px-3 py-2 text-sm">
                <button wire:click="createLgu" class="rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white">Add LGU</button>
            </div>

            <div class="mt-4 divide-y divide-border border-t border-border pt-2">
                @foreach ($lgus as $l)
                    <button wire:click="$set('selectedLguId', '{{ $l->id }}')" class="flex w-full items-center justify-between px-1 py-2 text-left text-sm {{ $selectedLguId === $l->id ? 'font-semibold text-accent' : '' }}">
                        <span>{{ $l->name }}</span>
                        <span class="font-mono text-xs text-muted">{{ $l->code }}</span>
                    </button>
                @endforeach
            </div>
        </div>

        <div class="rounded-card border border-border bg-surface p-5">
            <h2 class="text-xs font-semibold uppercase tracking-wide text-muted">
                Barangays @if($selectedLguId) — {{ $lgus->firstWhere('id', $selectedLguId)?->name }} @endif
            </h2>
            <div class="mt-3 flex gap-2">
                <input type="text" wire:model="barangayName" placeholder="Barangay name" class="flex-1 rounded-lg border border-border px-3 py-2 text-sm" @disabled(!$selectedLguId)>
                <button wire:click="createBarangay" class="rounded-lg bg-deep px-4 py-2 text-sm font-semibold text-white" @disabled(!$selectedLguId)>Add</button>
            </div>
            <ul class="mt-4 divide-y divide-border">
                @forelse ($barangays as $b)
                    <li class="py-2 text-sm">{{ $b->name }}</li>
                @empty
                    <li class="py-4 text-center text-sm text-muted">{{ $selectedLguId ? 'No barangays yet.' : 'Select an LGU first.' }}</li>
                @endforelse
            </ul>
        </div>
    </div>
</div>
