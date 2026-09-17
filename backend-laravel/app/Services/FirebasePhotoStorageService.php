<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Kreait\Firebase\Factory;

/**
 * Alternative to Cloudinary. Requires `composer require kreait/firebase-php`
 * and FIREBASE_CREDENTIALS + FIREBASE_STORAGE_BUCKET in .env. Only one of
 * Cloudinary/Firebase needs to be installed — pick one via
 * PHOTO_STORAGE_PROVIDER, you don't need both packages.
 */
class FirebasePhotoStorageService implements PhotoStorageServiceInterface
{
    private $bucket;

    public function __construct(string $credentialsPath, string $storageBucket)
    {
        $factory = (new Factory())->withServiceAccount($credentialsPath);
        $this->bucket = $factory->createStorage()->getBucket($storageBucket);
    }

    public function upload(UploadedFile $file, string $folder): UploadedPhoto
    {
        $objectName = trim($folder, '/').'/'.Str::uuid().'.'.$file->getClientOriginalExtension();

        $object = $this->bucket->upload(
            fopen($file->getRealPath(), 'r'),
            ['name' => $objectName]
        );
        $object->update(['acl' => []]); // rely on bucket-level public read rule
        $url = "https://firebasestorage.googleapis.com/v0/b/{$this->bucket->name()}/o/".
            rawurlencode($objectName).'?alt=media';

        return new UploadedPhoto(url: $url, storageKey: $objectName);
    }

    public function delete(string $storageKey): void
    {
        $this->bucket->object($storageKey)->delete();
    }

    public function providerName(): string
    {
        return 'firebase';
    }
}
