<?php

namespace App\Services;

/**
 * Used when AI_SEVERITY_PROVIDER=none (the default until you configure a
 * real provider). Every report gets "Moderate" pending manual review —
 * this keeps the app fully functional without any AI provider configured,
 * which matters for local development and for the Flutter app's offline
 * queue (severity is always assessed server-side once the report syncs,
 * never on-device).
 */
class NullSeverityService implements AiSeverityServiceInterface
{
    public function assess(string $imageUrl, string $categoryName, ?string $description = null): AiSeverityResult
    {
        return AiSeverityResult::fallback('no AI_SEVERITY_PROVIDER configured');
    }
}
