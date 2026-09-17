<?php

namespace App\Services;

use CloudinaryLabs\CloudinaryLaravel\Facades\Cloudinary;
use Illuminate\Http\UploadedFile;

/**
 * Requires cloudinary-labs/cloudinary-laravel and CLOUDINARY_URL in .env.
 * See https://cloudinary.com/documentation/laravel_integration
 */
class CloudinaryPhotoStorageService implements PhotoStorageServiceInterface
{
    public function upload(UploadedFile $file, string $folder): UploadedPhoto
    {
        $result = Cloudinary::upload($file->getRealPath(), [
            'folder' => $folder,
            'resource_type' => 'image',
        ]);

        return new UploadedPhoto(
            url: $result->getSecurePath(),
            storageKey: $result->getPublicId(),
        );
    }

    public function delete(string $storageKey): void
    {
        Cloudinary::destroy($storageKey);
    }

    public function providerName(): string
    {
        return 'cloudinary';
    }
}
