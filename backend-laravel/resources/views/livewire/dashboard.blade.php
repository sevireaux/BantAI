<div>
    <h1 class="text-2xl font-extrabold text-deep">Dashboard</h1>
    <p class="mt-1 text-sm text-muted">Overview of reports within your jurisdiction.</p>

    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div class="rounded-card border-l-4 border-secondary bg-surface p-4">
            <p class="text-2xl font-extrabold">{{ $statusCounts['Pending'] ?? 0 }}</p>
            <p class="text-xs text-muted">Pending</p>
        </div>
        <div class="rounded-card border-l-4 border-accent bg-surface p-4">
            <p class="text-2xl font-extrabold">{{ $statusCounts['In Progress'] ?? 0 }}</p>
            <p class="text-xs text-muted">In Progress</p>
        </div>
        <div class="rounded-card border-l-4 border-success bg-surface p-4">
            <p class="text-2xl font-extrabold">{{ $statusCounts['Resolved'] ?? 0 }}</p>
            <p class="text-xs text-muted">Resolved</p>
        </div>
        <div class="rounded-card border-l-4 border-severity-critical bg-surface p-4">
            <p class="text-2xl font-extrabold">{{ $severityCounts['Critical'] ?? 0 }}</p>
            <p class="text-xs text-muted">Critical severity (AI)</p>
        </div>
    </div>

    <div class="mt-8 grid gap-6 lg:grid-cols-2">
        <div>
            <h2 class="text-sm font-semibold uppercase tracking-wide text-muted">Recent reports</h2>
            <div class="mt-3 divide-y divide-border rounded-card border border-border bg-surface">
                @forelse ($recent as $r)
                    <a href="{{ route('admin.reports.show', $r->id) }}" class="flex items-center justify-between px-4 py-3 hover:bg-surface-alt">
                        <div>
                            <p class="font-medium">{{ $r->title }}</p>
                            <p class="text-xs text-muted">{{ $r->id }} · {{ $r->category?->name }}</p>
                        </div>
                        <span class="rounded-full bg-severity-{{ strtolower($r->severity) }} px-2 py-1 text-xs font-bold text-white">{{ $r->severity }}</span>
                    </a>
                @empty
                    <p class="px-4 py-6 text-center text-sm text-muted">No reports yet.</p>
                @endforelse
            </div>
        </div>

        <div>
            <h2 class="text-sm font-semibold uppercase tracking-wide text-muted">Top recurring locations</h2>
            <div class="mt-3 divide-y divide-border rounded-card border border-border bg-surface">
                @forelse ($topClusters as $c)
                    <div class="px-4 py-3">
                        <p class="font-medium">{{ $c->category?->name }} — {{ $c->barangay?->name ?? 'Unspecified' }}</p>
                        <p class="text-xs text-muted">{{ $c->report_count }} reports in this cluster</p>
                    </div>
                @empty
                    <p class="px-4 py-6 text-center text-sm text-muted">No clusters yet.</p>
                @endforelse
            </div>
        </div>
    </div>
</div>
