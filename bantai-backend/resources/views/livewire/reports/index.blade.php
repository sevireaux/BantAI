<div>
    <div class="flex items-center justify-between">
        <h1 class="text-2xl font-extrabold text-deep">Reports</h1>
    </div>

    <div class="mt-4 flex flex-wrap gap-2">
        <input type="text" wire:model.live.debounce.400ms="search" placeholder="Search title or ID…"
               class="rounded-lg border border-border bg-surface px-3 py-1.5 text-sm outline-none focus:border-accent" />
        @foreach (['All', 'Pending', 'Verified', 'In Progress', 'Resolved', 'Closed'] as $s)
            <button wire:click="$set('status', '{{ $s }}')"
                    class="rounded-full border px-3 py-1 text-xs font-medium {{ $status === $s ? 'border-accent bg-accent text-white' : 'border-border text-muted hover:bg-surface-alt' }}">
                {{ $s }}
            </button>
        @endforeach
    </div>

    <div class="mt-4 overflow-x-auto rounded-card border border-border bg-surface">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-border text-left text-xs uppercase tracking-wide text-muted">
                    <th class="px-4 py-3">Report</th>
                    <th class="px-4 py-3">Category</th>
                    <th class="px-4 py-3">Barangay</th>
                    <th class="px-4 py-3">Severity</th>
                    <th class="px-4 py-3">Status</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-border">
                @forelse ($reports as $r)
                    <tr wire:key="report-{{ $r->id }}" class="cursor-pointer hover:bg-surface-alt" onclick="window.location='{{ route('admin.reports.show', $r->id) }}'">
                        <td class="px-4 py-3">
                            <p class="font-medium">{{ $r->title }}</p>
                            <p class="text-xs text-muted">{{ $r->id }}</p>
                        </td>
                        <td class="px-4 py-3">{{ $r->category?->name }}</td>
                        <td class="px-4 py-3">{{ $r->barangay?->name ?? '—' }}</td>
                        <td class="px-4 py-3">
                            <span class="rounded-full bg-severity-{{ strtolower($r->severity) }} px-2 py-1 text-xs font-bold text-white">{{ $r->severity }}</span>
                        </td>
                        <td class="px-4 py-3">{{ $r->status }}</td>
                    </tr>
                @empty
                    <tr><td colspan="5" class="px-4 py-8 text-center text-muted">No reports match this filter.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $reports->links() }}</div>
</div>
