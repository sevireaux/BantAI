<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// NOTE: This REPLACES Laravel's default create_users_table migration.
// Delete the framework-generated one (database/migrations/..._create_users_table.php)
// before running this — see the root README's backend setup steps.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', [
                'citizen', 'barangay_admin', 'lgu_official', 'lgu_admin', 'system_admin',
            ])->default('citizen');
            $table->foreignUuid('lgu_id')->nullable()->constrained('lgus')->nullOnDelete();
            $table->foreignUuid('barangay_id')->nullable()->constrained('barangays')->nullOnDelete();
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();

            $table->index('role');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
