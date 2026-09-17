<?php

/**
 * NOT a real config file — copy these keys into your project's actual
 * config/services.php (inside the returned array, alongside the existing
 * 'mailgun', 'postmark', etc. entries). See the root README's backend setup
 * steps.
 */
return [

    'ai_severity' => [
        // "openai" | "none" (default — see App\Services\NullSeverityService)
        'provider' => env('AI_SEVERITY_PROVIDER', 'none'),
    ],

    'openai' => [
        'key' => env('OPENAI_API_KEY'),
        'severity_model' => env('OPENAI_SEVERITY_MODEL', 'gpt-4o-mini'),
    ],

    'cloudinary' => [
        'cloud_url' => env('CLOUDINARY_URL'),
    ],

    'photo_storage' => [
        // "cloudinary" (default) | "firebase"
        'provider' => env('PHOTO_STORAGE_PROVIDER', 'cloudinary'),
    ],

    'firebase' => [
        'credentials' => env('FIREBASE_CREDENTIALS'), // path to service-account JSON
        'storage_bucket' => env('FIREBASE_STORAGE_BUCKET'),
    ],

    'google_maps' => [
        // Server-side key, used for geocoding if you add it later.
        // The Flutter app uses its own separate Android API key — see the
        // Flutter setup section of the README.
        'server_key' => env('GOOGLE_MAPS_SERVER_KEY'),
    ],

];
