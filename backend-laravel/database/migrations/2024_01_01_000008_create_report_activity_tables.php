<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('status_history', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('report_id');
            $table->foreign('report_id')->references('id')->on('reports')->cascadeOnDelete();
            $table->string('status');
            $table->foreignUuid('changed_by')->nullable()->constrained('users');
            $table->text('note')->nullable();
            $table->timestamps();

            $table->index('report_id');
        });

        Schema::create('report_followers', function (Blueprint $table) {
            $table->string('report_id');
            $table->foreign('report_id')->references('id')->on('reports')->cascadeOnDelete();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->primary(['report_id', 'user_id']);
        });

        Schema::create('report_confirmations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('report_id');
            $table->foreign('report_id')->references('id')->on('reports')->cascadeOnDelete();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['report_id', 'user_id']);
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('report_id')->nullable();
            $table->foreign('report_id')->references('id')->on('reports')->cascadeOnDelete();
            $table->string('type');
            $table->string('title');
            $table->text('message');
            $table->boolean('read')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'read']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('report_confirmations');
        Schema::dropIfExists('report_followers');
        Schema::dropIfExists('status_history');
    }
};
