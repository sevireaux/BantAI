<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->string('id')->primary(); // human-readable, e.g. RPT-2026-000123

            // Generated on-device by the Flutter app at creation time (works
            // offline, before the server ever sees the report). Doubles as
            // the idempotency key when the offline queue syncs — retrying a
            // sync with the same client_uuid returns the original report
            // instead of creating a duplicate.
            $table->uuid('client_uuid')->unique();

            $table->foreignUuid('user_id')->constrained('users');
            $table->foreignUuid('lgu_id')->nullable()->constrained('lgus');
            $table->foreignUuid('barangay_id')->nullable()->constrained('barangays');
            $table->foreignUuid('category_id')->constrained('categories');
            $table->foreignUuid('subcategory_id')->nullable()->constrained('subcategories');

            $table->string('title');
            $table->text('description');
            $table->string('address')->nullable();
            $table->double('lat');
            $table->double('lng');

            $table->enum('status', [
                'Pending', 'Verified', 'In Progress', 'Resolved', 'Closed', 'Rejected', 'Duplicate', 'Cancelled',
            ])->default('Pending');

            // AI-determined severity (replaces the old community-report-count
            // based priority — see App\Services\AiSeverityService). An LGU
            // Official can override the AI's call during verification, which
            // flips severity_source to "manual" and records who/why.
            $table->enum('severity', ['Low', 'Moderate', 'High', 'Critical'])->default('Moderate');
            $table->float('severity_confidence')->nullable();
            $table->enum('severity_source', ['ai', 'manual'])->default('ai');
            $table->text('severity_reasoning')->nullable();
            $table->foreignUuid('severity_overridden_by')->nullable()->constrained('users');

            $table->foreignUuid('cluster_id')->nullable()->constrained('issue_clusters');
            $table->unsignedInteger('similar_report_count')->default(1);

            $table->timestamp('verified_at')->nullable();
            $table->foreignUuid('verified_by')->nullable()->constrained('users');
            $table->timestamp('resolved_at')->nullable();
            $table->foreignUuid('resolved_by')->nullable()->constrained('users');
            $table->timestamp('closed_at')->nullable();
            $table->foreignUuid('closed_by')->nullable()->constrained('users');
            $table->timestamp('cancelled_at')->nullable();

            $table->text('resolution_description')->nullable();
            $table->timestamp('resolution_date')->nullable();
            $table->text('invalid_reason')->nullable();

            // Barangay Administration — local validation / escalation
            // (advisory only; never changes status on their own).
            $table->boolean('barangay_confirmed')->default(false);
            $table->timestamp('barangay_confirmed_at')->nullable();
            $table->foreignUuid('barangay_confirmed_by')->nullable()->constrained('users');
            $table->text('barangay_note')->nullable();
            $table->boolean('priority_endorsed')->default(false);
            $table->text('priority_endorsement_reason')->nullable();
            $table->foreignUuid('priority_endorsed_by')->nullable()->constrained('users');
            $table->boolean('attention_requested')->default(false);
            $table->text('attention_requested_reason')->nullable();
            $table->foreignUuid('attention_requested_by')->nullable()->constrained('users');
            $table->boolean('recurring_flagged')->default(false);
            $table->foreignUuid('recurring_flagged_by')->nullable()->constrained('users');

            // When the report was actually created on the citizen's device —
            // may be well before `created_at` (server receipt time) if it
            // was queued offline. Null means it was submitted online as usual.
            $table->timestamp('device_submitted_at')->nullable();

            $table->timestamps();

            $table->index('status');
            $table->index('severity');
            $table->index(['lat', 'lng']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
