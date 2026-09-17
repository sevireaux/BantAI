<div>
    <a href="{{ route('admin.reports') }}" class="text-sm text-muted hover:text-deep">&larr; Back to reports</a>

    <div class="mt-2 flex items-start justify-between">
        <div>
            <p class="text-xs uppercase tracking-wide text-muted">{{ $report->id }} · {{ $report->user?->name }}</p>
            <h1 class="mt-1 text-2xl font-extrabold text-deep">{{ $report->title }}</h1>
            <p class="mt-1 text-sm text-muted">{{ $report->category?->name }} · {{ $report->subcategory?->name }} · {{ $report->barangay?->name }}</p>
        </div>
        <div class="flex flex-col items-end gap-2">
            <span class="rounded-full border border-border bg-surface-alt px-3 py-1 text-xs font-semibold">{{ $report->status }}</span>
            <span class="rounded-full bg-severity-{{ strtolower($report->severity) }} px-3 py-1 text-xs font-bold text-white">
                {{ $report->severity_source === 'ai' ? '✨ ' : '' }}{{ $report->severity }}
            </span>
        </div>
    </div>

    @if ($report->barangay_confirmed || $report->priority_endorsed || $report->attention_requested || $report->recurring_flagged)
        <div class="mt-3 flex flex-wrap gap-2 text-xs">
            @if ($report->barangay_confirmed) <span class="rounded-full border border-secondary/40 bg-secondary/10 px-2.5 py-1 font-medium">✓ Confirmed by Barangay</span> @endif
            @if ($report->priority_endorsed) <span class="rounded-full border border-accent/40 bg-accent/10 px-2.5 py-1 font-medium text-accent">⚑ Priority endorsed</span> @endif
            @if ($report->attention_requested) <span class="rounded-full border border-warning/40 bg-warning/10 px-2.5 py-1 font-medium">⚠ Attention requested</span> @endif
            @if ($report->recurring_flagged) <span class="rounded-full border border-border bg-surface-alt px-2.5 py-1 font-medium">↻ Recurring</span> @endif
        </div>
    @endif

    <div class="mt-6 grid gap-6 lg:grid-cols-3">
        <div class="space-y-6 lg:col-span-2">
            <div class="rounded-card border border-border bg-surface p-5">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-muted">Description</h2>
                <p class="mt-2 text-sm">{{ $report->description }}</p>
                @if ($report->severity_reasoning)
                    <div class="mt-3 rounded-lg bg-surface-alt p-3 text-xs text-deep">
                        <strong>AI assessment:</strong> {{ $report->severity_reasoning }}
                        @if ($report->severity_confidence) (confidence: {{ round($report->severity_confidence * 100) }}%) @endif
                    </div>
                @endif
                @if ($report->photos->where('kind', 'evidence')->count())
                    <div class="mt-4 flex flex-wrap gap-2">
                        @foreach ($report->photos->where('kind', 'evidence') as $photo)
                            <a href="{{ $photo->url }}" target="_blank"><img src="{{ $photo->url }}" class="h-20 w-20 rounded-lg object-cover"></a>
                        @endforeach
                    </div>
                @endif
                <p class="mt-4 text-sm text-muted">{{ $report->address }}</p>
                <p class="mt-1 text-sm font-semibold text-accent">{{ $report->similar_report_count }} similar reports nearby</p>
            </div>

            @can('barangayAct', $report)
                @if (in_array($report->status, ['Pending', 'Verified', 'In Progress']))
                    <div class="rounded-card border border-secondary/40 bg-secondary/10 p-5">
                        <h2 class="text-xs font-semibold uppercase tracking-wide text-deep">Barangay Administration</h2>

                        <div class="mt-3 border-t border-secondary/20 pt-3">
                            <label class="block text-sm font-medium">Confirm locally</label>
                            <textarea wire:model="barangayNote" rows="2" class="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm"></textarea>
                            <button wire:click="barangayConfirm" class="mt-2 rounded-lg bg-secondary px-4 py-2 text-sm font-semibold text-deep">Confirm locally</button>
                        </div>

                        <div class="mt-4 border-t border-secondary/20 pt-3">
                            <label class="block text-sm font-medium">Endorse for higher priority</label>
                            <textarea wire:model="justification" rows="2" placeholder="Written justification (required)" class="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm"></textarea>
                            <button wire:click="endorsePriority" class="mt-2 rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white">Submit endorsement</button>
                        </div>

                        <div class="mt-4 border-t border-secondary/20 pt-3">
                            <label class="block text-sm font-medium">Request LGU attention</label>
                            <select wire:model="attentionReason" class="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm">
                                @foreach (['urgent','significant','recurring','access-related','safety-related','long-pending'] as $reason)
                                    <option value="{{ $reason }}">{{ ucfirst(str_replace('-', ' ', $reason)) }}</option>
                                @endforeach
                            </select>
                            <textarea wire:model="attentionDetail" rows="2" placeholder="Detail (optional)" class="mt-2 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm"></textarea>
                            <button wire:click="requestAttention" class="mt-2 rounded-lg border border-warning px-4 py-2 text-sm font-semibold text-warning">Request attention</button>
                        </div>

                        <div class="mt-4 border-t border-secondary/20 pt-3">
                            <button wire:click="flagRecurring" class="rounded-lg border border-border px-4 py-2 text-sm font-semibold hover:bg-surface">Flag as recurring</button>
                        </div>
                    </div>
                @endif
            @endcan

            @if (in_array(auth()->user()->role, ['lgu_official', 'lgu_admin']))
                @if ($report->status === 'Pending')
                    <div class="rounded-card border border-warning/40 bg-warning/10 p-5">
                        <h2 class="text-xs font-semibold uppercase tracking-wide">Verification needed</h2>
                        <textarea wire:model="verifyNote" rows="2" placeholder="Verification notes" class="mt-2 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm"></textarea>
                        <div class="mt-2 flex gap-2">
                            <button wire:click="verify('verified')" class="rounded-lg bg-success px-4 py-2 text-sm font-semibold text-white">Verify</button>
                            <button wire:click="verify('rejected')" class="rounded-lg border border-accent px-4 py-2 text-sm font-semibold text-accent">Reject</button>
                        </div>
                    </div>
                @endif

                @if ($report->status === 'Verified')
                    <div class="rounded-card border border-border bg-surface p-5">
                        <button wire:click="markInProgress" class="rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white">Mark In Progress</button>
                    </div>
                @endif

                @if ($report->status === 'In Progress')
                    <div class="rounded-card border border-accent/40 bg-accent/10 p-5">
                        <h2 class="text-xs font-semibold uppercase tracking-wide text-accent">Resolve with evidence</h2>
                        <textarea wire:model="resolveDescription" rows="2" placeholder="Resolution description" class="mt-2 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm"></textarea>
                        <input type="file" wire:model="resolvePhotos" multiple class="mt-2 text-sm" accept="image/*">
                        <button wire:click="resolve" class="mt-2 rounded-lg bg-success px-4 py-2 text-sm font-semibold text-white">Confirm resolved</button>
                    </div>
                @endif

                @if ($report->status === 'Resolved')
                    <div class="rounded-card border border-success/40 bg-success/10 p-5">
                        <p class="text-sm">{{ $report->resolution_description }}</p>
                        <button wire:click="close" class="mt-2 rounded-lg bg-deep px-4 py-2 text-sm font-semibold text-white">Close report</button>
                    </div>
                @endif
            @endif
        </div>

        <div>
            <h2 class="text-xs font-semibold uppercase tracking-wide text-muted">Status timeline</h2>
            <div class="mt-3 space-y-3 rounded-card border border-border bg-surface p-4">
                @foreach ($report->statusHistory as $h)
                    <div>
                        <p class="text-sm font-semibold">{{ $h->status }}</p>
                        <p class="text-xs text-muted">{{ $h->created_at->format('M j, Y g:ia') }}</p>
                        @if ($h->note) <p class="text-xs">{{ $h->note }}</p> @endif
                    </div>
                @endforeach
            </div>
        </div>
    </div>
</div>
