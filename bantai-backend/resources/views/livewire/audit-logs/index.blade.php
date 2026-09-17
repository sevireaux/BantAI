<div>
    <h1 class="text-2xl font-extrabold text-deep">Audit logs</h1>
    <p class="mt-1 text-sm text-muted">
        Report-related and administrative actions only — logins and sign-ups are never recorded here.
    </p>

    <div class="mt-6 overflow-x-auto rounded-card border border-border bg-surface">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-border text-left text-xs uppercase tracking-wide text-muted">
                    <th class="px-4 py-3">When</th>
                    <th class="px-4 py-3">Actor</th>
                    <th class="px-4 py-3">Action</th>
                    <th class="px-4 py-3">Target</th>
                    <th class="px-4 py-3">IP</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-border">
                @forelse ($logs as $log)
                    <tr>
                        <td class="whitespace-nowrap px-4 py-3 text-muted">{{ $log->created_at->format('M j, Y g:ia') }}</td>
                        <td class="px-4 py-3">
                            <p class="font-medium">{{ $log->user?->name ?? 'System' }}</p>
                            <p class="text-xs text-muted">{{ $log->user?->email }}</p>
                        </td>
                        <td class="px-4 py-3">{{ str_replace('_', ' ', $log->action) }}</td>
                        <td class="px-4 py-3 text-muted">{{ $log->target_type }}{{ $log->target_id ? " · {$log->target_id}" : '' }}</td>
                        <td class="px-4 py-3 font-mono text-xs text-muted">{{ $log->ip_address }}</td>
                    </tr>
                @empty
                    <tr><td colspan="5" class="px-4 py-8 text-center text-muted">No audit entries yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $logs->links() }}</div>
</div>
