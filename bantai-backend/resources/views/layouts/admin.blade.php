<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title ?? 'BantAI Admin' }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-primary text-[#3A2A1E] antialiased">
    <div class="flex min-h-screen">
        <aside class="w-64 shrink-0 border-r border-border bg-surface px-4 py-6">
            <a href="{{ route('admin.dashboard') }}" class="block text-xl font-extrabold text-deep mb-8">
                Bant<span class="text-accent">AI</span>
            </a>

            <nav class="space-y-1 text-sm">
                @php
                    $user = auth()->user();
                    $links = [
                        ['route' => 'admin.dashboard', 'label' => 'Dashboard'],
                        ['route' => 'admin.reports', 'label' => 'Reports'],
                    ];
                    if ($user->role === 'system_admin') {
                        $links[] = ['route' => 'admin.staff', 'label' => 'Staff Accounts'];
                        $links[] = ['route' => 'admin.organizations', 'label' => 'LGUs & Barangays'];
                        $links[] = ['route' => 'admin.orphaned-reports', 'label' => 'Orphaned Reports'];
                        $links[] = ['route' => 'admin.audit-logs', 'label' => 'Audit Logs'];
                    } elseif ($user->role === 'lgu_admin') {
                        $links[] = ['route' => 'admin.staff', 'label' => 'Manage Staff'];
                    }
                @endphp

                @foreach ($links as $link)
                    <a href="{{ route($link['route']) }}"
                       class="block rounded-lg px-3 py-2 transition {{ request()->routeIs($link['route'].'*') ? 'bg-accent text-white font-semibold' : 'text-[#3A2A1E] hover:bg-surface-alt' }}">
                        {{ $link['label'] }}
                    </a>
                @endforeach
            </nav>

            <div class="mt-10 border-t border-border pt-4 text-xs">
                <p class="font-semibold">{{ $user->name }}</p>
                <p class="text-muted">{{ ucwords(str_replace('_', ' ', $user->role)) }}</p>
                <form method="POST" action="{{ route('admin.logout') }}" class="mt-2">
                    @csrf
                    <button type="submit" class="text-accent hover:underline">Log out</button>
                </form>
            </div>
        </aside>

        <main class="flex-1 px-8 py-8">
            @if (session('status'))
                <div class="mb-4 rounded-lg border border-success/30 bg-success/10 px-4 py-2 text-sm text-success">
                    {{ session('status') }}
                </div>
            @endif

            {{ $slot }}
        </main>
    </div>
</body>
</html>
