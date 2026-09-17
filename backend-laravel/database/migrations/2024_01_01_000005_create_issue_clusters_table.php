<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('issue_clusters', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('category_id')->constrained('categories');
            $table->foreignUuid('subcategory_id')->nullable()->constrained('subcategories');
            $table->foreignUuid('barangay_id')->nullable()->constrained('barangays');
            $table->double('center_lat');
            $table->double('center_lng');
            $table->unsignedInteger('report_count')->default(0);
            $table->timestamps();

            $table->index(['center_lat', 'center_lng']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('issue_clusters');
    }
};
