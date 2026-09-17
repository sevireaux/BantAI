<div>
    <h1 class="text-2xl font-extrabold text-deep">Orphaned reports</h1>
    <p class="mt-1 text-sm text-muted">
        These reports have no LGU assigned — usually submitted before any LGU existed. Until assigned, no LGU/Barangay staff can see them.
    </p>

    <div class="mt-6 divide-y divide-border rounded-card border border-border bg-surface">
        @forelse ($reports as $r)
            <div wire:key="orphan-{{ $r->id }}" class="flex flex-wrap items-center justify-between gap-3 px-4 py-3">
                <div>
                    <p class="font-medium">{{ $r->title }}</p>
                    <p class="text-xs text-muted">{{ $r->id }} · {{ $r->category?->name }} · {{ $r->address }}</p>
                </div>
                <div class="flex items-center gap-2">
                    <select wire:model="lguChoice.{{ $r->id }}" class="rounded-lg border border-border px-2 py-1 text-xs">
                        <option value="">Select LGU</option>
                        @foreach ($lgus as $l)
                            <option value="{{ $l->id }}">{{ $l->name }}</option>
                        @endforeach
                    </select>
                    @if (! empty($lguChoice[$r->id]))
                        <select wire:model="barangayChoice.{{ $r->id }}" class="rounded-lg border border-border px-2 py-1 text-xs">
                            <option value="">Barangay (optional)</option>
                            @foreach ($this->barangaysFor($r->id) as $b)
                                <option value="{{ $b->id }}">{{ $b->name }}</option>
                            @endforeach
                        </select>
                    @endif
                    <button wire:click="assign('{{ $r->id }}')" class="rounded-lg bg-accent px-3 py-1.5 text-xs font-semibold text-white">Assign</button>
                </div>
            </div>
        @empty
            <p class="px-4 py-8 text-center text-muted">None — every report currently has an LGU assigned.</p>
        @endforelse
    </div>
</div>
