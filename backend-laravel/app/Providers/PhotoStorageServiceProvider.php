<?php

namespace App\Providers;

use App\Services\CloudinaryPhotoStorageService;
use App\Services\FirebasePhotoStorageService;
use App\Services\PhotoStorageServiceInterface;
use Illuminate\Support\ServiceProvider;

class PhotoStorageServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(PhotoStorageServiceInterface::class, function () {
            return match (config('services.photo_storage.provider', 'cloudinary')) {
                'firebase' => new FirebasePhotoStorageService(
                    credentialsPath: (string) config('services.firebase.credentials'),
                    storageBucket: (string) config('services.firebase.storage_bucket'),
                ),
                default => new CloudinaryPhotoStorageService(),
            };
        });
    }
}
