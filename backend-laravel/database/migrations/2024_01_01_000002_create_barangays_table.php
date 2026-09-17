<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('barangays', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('lgu_id')->constrained('lgus')->cascadeOnDelete();
            $table->string('name');
            $table->timestamps();
            $table->unique(['lgu_id', 'name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('barangays');
    }
};
