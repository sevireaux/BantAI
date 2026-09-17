<?php

namespace App\Services;

final class UploadedPhoto
{
    public function __construct(
        public readonly string $url,
        public readonly string $storageKey,
    ) {}
}
