<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_photos', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('report_id');
            $table->foreign('report_id')->references('id')->on('reports')->cascadeOnDelete();

            // Photos live in Cloudinary/Firebase Storage, never in the DB —
            // see App\Services\PhotoStorageService. `url` is the public CDN
            // URL; `storage_key` is the provider's asset id/path, needed to
            // delete or transform the asset later.
            $table->string('url');
            $table->string('storage_key')->nullable();
            $table->enum('provider', ['cloudinary', 'firebase'])->default('cloudinary');
            $table->enum('kind', [
                'evidence', 'resolution_before', 'resolution_after', 'resolution_document', 'barangay_evidence',
            ])->default('evidence');
            $table->foreignUuid('uploaded_by')->nullable()->constrained('users');
            $table->timestamps();

            $table->index('report_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_photos');
    }
};
