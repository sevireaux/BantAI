<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log in — BantAI Admin</title>
    @vite(['resources/css/app.css'])
</head>
<body class="bg-primary text-[#3A2A1E] antialiased">
    <div class="flex min-h-screen items-center justify-center px-4">
        <div class="w-full max-w-sm">
            <h1 class="text-2xl font-extrabold text-deep">Bant<span class="text-accent">AI</span> Admin</h1>
            <p class="mt-1 text-sm text-muted">For LGU/System Administrator and staff accounts only.</p>

            <form method="POST" action="{{ route('admin.login.attempt') }}" class="mt-6 space-y-4">
                @csrf
                <div>
                    <label class="mb-1 block text-sm font-medium">Email address</label>
                    <input type="email" name="email" value="{{ old('email') }}"
                           class="w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-accent" />
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium">Password</label>
                    <input type="password" name="password"
                           class="w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-accent" />
                </div>

                @if ($errors->any())
                    <div class="rounded-lg border border-accent/30 bg-accent/10 px-3 py-2 text-sm text-accent">
                        {{ $errors->first() }}
                    </div>
                @endif

                <button type="submit" class="w-full rounded-lg bg-accent px-4 py-2.5 font-semibold text-white transition hover:opacity-90">
                    Log in
                </button>
            </form>
        </div>
    </div>
</body>
</html>
