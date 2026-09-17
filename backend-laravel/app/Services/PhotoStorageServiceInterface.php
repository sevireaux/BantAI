<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;

/**
 * Photos are never stored in the database or on the app server's own disk
 * — only the resulting CDN URL is persisted (report_photos.url). Swap
 * providers by changing PHOTO_STORAGE_PROVIDER in .env.
 */
interface PhotoStorageServiceInterface
{
    public function upload(UploadedFile $file, string $folder): UploadedPhoto;

    public function delete(string $storageKey): void;

    public function providerName(): string;
}
