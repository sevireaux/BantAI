# BantAI — Mobile Migration (Flutter + Laravel + PostgreSQL)

This is BantAI rebuilt on a new stack: an Android app (Flutter/Dart) talking
to a Laravel REST API, backed by PostgreSQL, with photo storage on
Cloudinary/Firebase, Google Maps for location, AI-assessed report severity,
and offline-first report submission via Drift/SQLite. A Laravel
Livewire admin panel replaces the old Next.js web app for LGU/System staff.

```
Android App          Backend API           Database
Flutter + Dart  <-->  Laravel + PHP  <-->   PostgreSQL
(+ Drift/SQLite            |
 offline queue)            v
                    Admin Web Panel
                    Laravel + Livewire
                    (LGU/System staff)

Cross-cutting: Google Maps Platform (location), Cloudinary/Firebase
(photos), an AI vision provider (severity assessment), Sanctum (mobile
auth tokens) + Laravel session auth (admin panel).
```

```
bantai-mobile/
├── backend-laravel/     # Laravel API + Livewire admin panel (see its NOTES.md)
└── mobile-flutter/      # Flutter Android app (see its NOTES.md)
```

**Read this before touching either folder:** neither `backend-laravel/` nor
`mobile-flutter/` is a complete, ready-to-run project by itself. Both
Laravel and Flutter generate a large amount of framework scaffolding via
their own CLIs (`composer create-project`, `flutter create`) that isn't
something to hand-write — this repo contains the hand-written *application
code* that overlays onto that generated scaffolding. Every section below
says exactly when to run the generator and when to copy files in.

---

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Set up PostgreSQL](#2-set-up-postgresql)
3. [Set up the Laravel backend](#3-set-up-the-laravel-backend)
4. [Configure photo storage (Cloudinary or Firebase)](#4-configure-photo-storage-cloudinary-or-firebase)
5. [Configure AI severity assessment](#5-configure-ai-severity-assessment)
6. [Migrate, seed, and run the backend](#6-migrate-seed-and-run-the-backend)
7. [Creating the first administrative account](#7-creating-the-first-administrative-account)
8. [Access the Livewire admin panel](#8-access-the-livewire-admin-panel)
9. [Set up the Flutter Android app](#9-set-up-the-flutter-android-app)
10. [Google Maps setup](#10-google-maps-setup)
11. [Running the app](#11-running-the-app)
12. [How offline reporting actually works](#12-how-offline-reporting-actually-works)
13. [The role & permission system](#13-the-role--permission-system)
14. [The design system](#14-the-design-system)
15. [What's fully built vs. scaffolded](#15-whats-fully-built-vs-scaffolded)

---

## 1. Prerequisites

Install these before starting:

| Tool | Version | Check with |
|---|---|---|
| PHP | 8.2+ | `php -v` |
| Composer | 2.x | `composer -V` |
| PostgreSQL | 14+ | `psql --version` |
| Node.js + npm | 18+ (for Vite, the admin panel's asset bundler) | `node -v` |
| Flutter SDK | 3.22+ (Dart 3.3+) | `flutter --version` |
| Android Studio | latest, with an emulator or a physical device | — |

You'll also want accounts for: **Cloudinary** *or* **Firebase** (photo
storage), **Google Cloud** (Maps Platform API key), and **OpenAI** *or
another vision-capable AI provider* (severity assessment) — all have free
tiers sufficient for development.

---

## 2. Set up PostgreSQL

```bash
psql postgres
```

```sql
CREATE USER bantai_user WITH PASSWORD 'bantai_pass';
CREATE DATABASE bantai_db OWNER bantai_user;
\q
```

---

## 3. Set up the Laravel backend

```bash
composer create-project laravel/laravel bantai-backend
cd bantai-backend
composer require laravel/sanctum livewire/livewire guzzlehttp/guzzle cloudinary-labs/cloudinary-laravel
```

(Skip `cloudinary-labs/cloudinary-laravel` if you're using Firebase Storage
instead — see Section 4. `laravel/sanctum` ships bundled with Laravel 11 by
default, but the require above is harmless if it's already present.)

Now copy this repo's custom application code into your fresh project,
**overwriting** where paths collide:

```bash
# From inside bantai-backend/, adjust the source path to wherever you
# extracted this repo:
SRC=../bantai-mobile/backend-laravel

cp -r $SRC/app/* app/
cp -r $SRC/database/migrations/* database/migrations/
cp -r $SRC/database/seeders/* database/seeders/
cp $SRC/routes/api.php routes/api.php
cp $SRC/routes/web.php routes/web.php
cp -r $SRC/resources/views/* resources/views/
cp $SRC/tailwind.config.js .
```

**Important — manual merges, because these files already exist with content
you shouldn't blindly overwrite:**

1. **`database/migrations/`** — delete Laravel's default
   `..._create_users_table.php` (the one from `composer create-project`,
   *not* the one you just copied in) — the copied version replaces it with
   the role/jurisdiction-aware schema. Also run:
   ```bash
   php artisan vendor:publish --tag=sanctum-migrations
   ```
   to get Sanctum's `personal_access_tokens` migration (needed for mobile
   API tokens).

2. **`config/services.php`** — open `backend-laravel/config/services.additions.php`
   and copy its array entries into your real `config/services.php`
   (inside the array Laravel already returns).

3. **`config/app.php`** — add the one key from
   `backend-laravel/config/app.additions.php` into your real `config/app.php`.

4. **`app/Http/Controllers/Controller.php`** — the copied version adds
   `AuthorizesRequests`, which every controller here needs. Confirm it
   overwrote Laravel's minimal default (it should have, from the `cp -r`
   above).

**Register the two new service providers and the `role` middleware alias**
in `bootstrap/providers.php` and `bootstrap/app.php`:

```php
// bootstrap/providers.php — add to the returned array:
App\Providers\AiSeverityServiceProvider::class,
App\Providers\PhotoStorageServiceProvider::class,
```

```php
// bootstrap/app.php — inside ->withMiddleware(function (Middleware $middleware) { ... }):
$middleware->alias(['role' => \App\Http\Middleware\EnsureRole::class]);
```

Set up your `.env`:

```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=bantai_db
DB_USERNAME=bantai_user
DB_PASSWORD=bantai_pass

SANCTUM_STATEFUL_DOMAINS=localhost
SESSION_DRIVER=database

# One-time secret for the first System Administrator — see Section 7.
SYSTEM_ADMIN_SETUP_KEY=
```

---

## 4. Configure photo storage (Cloudinary or Firebase)

Pick one — you don't need both packages installed.

### Option A: Cloudinary (default)

```
PHOTO_STORAGE_PROVIDER=cloudinary
CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
```

Get this from your Cloudinary dashboard's "API Environment variable" field.

### Option B: Firebase Storage

```bash
composer require kreait/firebase-php
```

```
PHOTO_STORAGE_PROVIDER=firebase
FIREBASE_CREDENTIALS=/absolute/path/to/service-account.json
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

Download the service-account JSON from Firebase Console → Project Settings
→ Service Accounts → Generate new private key. **Never commit this file.**

---

## 5. Configure AI severity assessment

This replaces the old "priority from number of similar reports" system
entirely — severity is now assessed from the report's photo the moment it's
submitted.

```
AI_SEVERITY_PROVIDER=openai
OPENAI_API_KEY=sk-...
OPENAI_SEVERITY_MODEL=gpt-4o-mini
```

Leave `AI_SEVERITY_PROVIDER` unset (or `none`) to run without AI during
development — every report gets "Moderate" severity pending manual review,
and the app stays fully functional. See `app/Services/AiSeverityServiceInterface.php`
if you want to add a different provider (Google Cloud Vision, AWS
Rekognition, a self-hosted model) — implement the interface, wire it into
`AiSeverityServiceProvider`'s match expression, done.

---

## 6. Migrate, seed, and run the backend

```bash
php artisan migrate
php artisan db:seed
php artisan serve
```

This starts the API at `http://localhost:8000`. Confirm it's up:

```bash
curl http://localhost:8000/api/health
```

The seeder creates default categories/subcategories, one demo LGU
("Quezon City LGU"), two barangays, and **one citizen demo account**
(`citizen@example.com` / `Password123!`) — no staff accounts, matching the
strict account-creation policy in Section 7.

For the admin panel's assets:

```bash
npm install
npm run build     # or `npm run dev` while actively developing the panel
```

---

## 7. Creating the first administrative account

Same strict policy as the web version of BantAI: public sign-up only ever
creates Citizens, and the only way to create the very first System
Administrator is a one-time, secret-gated bootstrap call that permanently
disables itself once used.

1. Generate a random key and set it as `SYSTEM_ADMIN_SETUP_KEY` in `.env`,
   then restart `php artisan serve`:
   ```bash
   php -r "echo bin2hex(random_bytes(32)), PHP_EOL;"
   ```
2. Call the bootstrap endpoint (there's no UI for this deliberately — it's
   a one-time operational step, not a feature):
   ```bash
   curl -X POST http://localhost:8000/api/auth/bootstrap-admin \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Your Name",
       "email": "admin@yourlgu.gov.ph",
       "password": "a-very-long-password-here",
       "setupKey": "the-key-you-generated-above"
     }'
   ```
3. It refuses to run again once any System Administrator exists, and
   refuses to run at all without the correct `setupKey`. **Immediately
   after success**, clear `SYSTEM_ADMIN_SETUP_KEY` in `.env` and restart —
   leaving it set is unnecessary risk even though the endpoint is already
   self-disabled.
4. Log into the admin panel (Section 8) with that account. From there,
   create LGU Administrators, who create their own Barangay
   Administrators and LGU Officials — see Section 13.

---

## 8. Access the Livewire admin panel

With the backend running (`php artisan serve`) and assets built
(`npm run build`), visit:

```
http://localhost:8000/admin/login
```

Log in with the System Administrator account from Section 7. Citizens
cannot log in here — the login form checks for that and rejects it.

---

## 9. Set up the Flutter Android app

```bash
flutter create --org com.bantai --project-name bantai_mobile bantai_mobile_app
cd bantai_mobile_app
```

Copy this repo's Flutter code in, overwriting the generated `lib/` and
`pubspec.yaml`:

```bash
SRC=../bantai-mobile/mobile-flutter

rm -rf lib
cp -r $SRC/lib .
cp $SRC/pubspec.yaml .
cp $SRC/android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
```

Install dependencies and generate Drift's database code (this is the one
build step Drift requires — it reads the `@DriftDatabase` annotation in
`lib/data/local/app_database.dart` and generates `app_database.g.dart`):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Follow `mobile-flutter/android/NOTES.md` (copied in as
`bantai_mobile_app/android/NOTES.md` — or just read it from this repo) to
wire the Google Maps API key through `android/local.properties`.

---

## 10. Google Maps setup

1. In [Google Cloud Console](https://console.cloud.google.com/), create a
   project (or use an existing one) and enable **Maps SDK for Android** and
   **Geocoding API**.
2. Create an API key, restricted to Android apps with your app's package
   name (`com.bantai.bantai_mobile_app` if you used the command above) and
   SHA-1 signing fingerprint (`./gradlew signingReport` in
   `android/` gives you this for debug builds).
3. Add it to `android/local.properties`:
   ```
   googleMaps.apiKey=AIzaSy...your-real-key...
   ```
   (See `android/NOTES.md` for the one `build.gradle` snippet this depends
   on, if `flutter create` didn't already wire manifest placeholders for
   you.)

---

## 11. Running the app

Point the app at your backend. The Android emulator reaches your host
machine's `localhost` via the special address `10.0.2.2` — this is already
the default in `lib/core/constants.dart`, so for the emulator you can just
run:

```bash
flutter run
```

For a physical device on the same network, or a deployed backend, override
it at build/run time instead of editing the source:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000/api
```

Log in with the citizen demo account (`citizen@example.com` /
`Password123!`) to try the report-submission flow, or your bootstrapped
System Administrator account to see the LGU/Barangay side (the mobile app
shows the LGU dashboard/reports/map for any non-citizen role; the fuller
staff-management screens live in the Livewire admin panel instead).

**Try the offline flow specifically:** turn on Airplane Mode, submit a
report with a photo — you'll get the "Saved offline" dialog instead of an
error. Turn Airplane Mode back off and watch the banner at the top of the
screen switch to "Sending queued reports…" and then disappear once it
syncs. Check the Livewire admin panel's Reports list — the report is there
with a real AI-assessed severity, exactly as if it had been submitted
online.

---

## 12. How offline reporting actually works

This is the piece that makes "report while offline, it sends itself later"
actually true rather than just a claim, so it's worth understanding end to
end:

1. **Submission always tries online first** (`ReportRepository.submitReport`
   in `mobile-flutter/lib/data/repositories/report_repository.dart`) if the
   device reports connectivity. Only a genuine network failure (not a
   validation error, not a 403) falls through to queueing — a real error
   from the server is still surfaced to the user immediately, online or not.
2. **Queueing** copies the picked photos from their temporary picker
   location into permanent app storage (temp files can be cleared by the OS
   at any time) and inserts one row into Drift's `PendingReports` table,
   including a `clientUuid` generated on-device.
3. **`ReportSyncService`** listens for connectivity changes
   (`connectivity_plus`) and, the moment the device reconnects, drains the
   queue sequentially — one report at a time, so a shaky connection doesn't
   fire five uploads simultaneously.
4. **The `clientUuid` is the idempotency key** the Laravel backend checks
   (`ReportController::store`) — if a sync attempt partially succeeds (the
   server saves the report but the response is lost to a dropped
   connection) and the app retries, the server recognizes the same
   `clientUuid` and returns the original report instead of creating a
   duplicate.
5. **AI severity assessment happens server-side, once, at the point the
   report actually reaches the server** — never on-device. This means a
   report queued offline for three days gets exactly the same severity
   assessment as one submitted instantly; the offline delay doesn't change
   how it's evaluated.
6. **Failures** (not network-related — e.g. a category that got deleted
   server-side while the report sat in the queue) mark the row `failed`
   with the error message kept for review, and stop being retried
   automatically after 5 attempts, so a permanently-broken row doesn't spin
   forever on every reconnect.

---

## 13. The role & permission system

Unchanged in principle from the web version, re-implemented in Laravel:

| Level | Role | Scope | Authority |
|---|---|---|---|
| 1 | System Administrator | Entire platform | Highest authority; creates LGU Administrators |
| 2 | LGU Administrator | One LGU | Creates Barangay Administrators & LGU Officials for their LGU |
| 3 | Barangay Administrator | One barangay | Local validation, evidence, priority endorsement, escalation |
| 4 | LGU Official | Assigned LGU | Formal verification, status updates, resolution, closure |
| 5 | Citizen | Own reports | Report and track civic issues |

- **Role** is enforced by the `role:...` middleware alias
  (`app/Http/Middleware/EnsureRole.php`) on routes.
- **Jurisdiction** — which specific LGU/barangay/report a user may touch —
  is enforced separately by `app/Policies/ReportPolicy.php` and
  `Report::scopeVisibleTo()`, checked on every read and write. A System
  Administrator always passes; everyone else is scoped to their own
  LGU/barangay/reports only.
- **Account creation** follows the same strict chain as before: public
  sign-up → Citizen only; System Administrator → LGU Administrator/System
  Administrator only; LGU Administrator → Barangay Administrator/LGU
  Official only, within their own LGU. See `AdminController::ALLOWED_ASSIGNMENTS`
  and `StaffAccounts\Index::ALLOWED_ASSIGNMENTS` (API and Livewire enforce
  the identical rule independently).
- **Audit logging tracks report-related and administrative actions
  only** — `App\Services\AuditLogger` is never called from
  `AuthController` or `LoginController`'s login/signup/logout methods, by
  design. If you're extending auth, don't add logging there; that's a
  deliberate, not accidental, omission (per your requirement that the
  System Administrator dashboard shouldn't track sign-ins).

---

## 14. The design system

Applied consistently across both the Flutter app and the Livewire admin
panel from the same four colors:

| Color | Hex | Role |
|---|---|---|
| Primary (beige) | `#F5F5DC` | Canvas/background only — never small text or icons |
| Secondary (sandy brown) | `#F4A460` | Secondary emphasis: selected states, non-alert badges |
| Accent (terracotta) | `#E35336` | The **one** primary action per screen, or a genuine alert |
| Deep (sienna) | `#A0522D` | Headings and high-emphasis text — not pure black |

Composition rules (see the docblock in `mobile-flutter/lib/core/theme.dart`
for the full reasoning):
- An 8px spacing scale, applied everywhere — no ad-hoc padding values.
- Consistent corner radii: 12px for cards, 8px for inputs/chips, never
  mixed on the same screen.
- The accent color is reserved for one thing at a time. If everything on a
  screen is colored like an alert, nothing reads as one — so status,
  severity, and action colors are kept visually distinct (status = outline
  chip, severity = solid fill, primary action = the only solid accent
  button on the screen).

**Animation** is deliberately minimal, per the brief: a single `AppMotion`
constant set (150/220/300ms, `Curves.easeOut`, nothing longer, nothing that
bounces or overshoots) used for exactly three things — a pulsing dot on
"Pending" status badges, a smooth color transition when a badge's status
changes, and a brief fade when switching bottom-nav tabs or opening a
modal. Nothing else in the app animates.

---

## 15. What's fully built vs. scaffolded

**Fully built and working end to end:** authentication (Sanctum + admin
session), the complete citizen report lifecycle (submit → verify → in
progress → resolve → close) including offline queueing and sync, AI
severity assessment with a working OpenAI reference implementation, all
four Barangay Administration actions, jurisdiction enforcement, the strict
account-creation hierarchy (API and Livewire, independently enforced), the
civic map (pins + hotspots), notifications, and the orphaned-report repair
tool.

**Present but intentionally minimal, worth extending:**
- The Flutter app's LGU/Barangay side covers the essentials (dashboard,
  reports list/detail with full actions); the deeper staff-management
  screens (creating other staff accounts) live only in the Livewire admin
  panel, not the mobile app — matching a "citizens and field staff use the
  app; office staff use the web panel" split, but easy to add to Flutter if
  you want staff management on mobile too.
- Push notifications aren't wired up (the in-app notification list is) —
  add Firebase Cloud Messaging if you want real push.
- The offline queue handles report *creation* only — editing/cancelling a
  report requires connectivity, since those are rarer, less time-sensitive
  actions.
- No automated test suite is included for either the Laravel or Flutter
  code — worth adding before any production deployment.
