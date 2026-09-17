<?php

namespace App\Services;

/**
 * Determines a civic report's severity from its photo evidence, replacing
 * the old "count of similar reports" approach entirely — severity now comes
 * from what the image actually shows, decided once at submission time (and
 * overridable by an LGU Official during verification, since AI calls are
 * not perfect).
 *
 * This is intentionally provider-agnostic: AiSeverityResult is the only
 * contract the rest of the app depends on. Swap providers by changing
 * AI_SEVERITY_PROVIDER in .env — see config/services.php and
 * AiSeverityServiceProvider.
 */
interface AiSeverityServiceInterface
{
    /**
     * @param  string  $imageUrl  Publicly reachable URL of the uploaded photo
     *                            (Cloudinary/Firebase URL — the provider
     *                            fetches it directly, nothing is uploaded
     *                            twice).
     * @param  string  $categoryName  e.g. "Roads", "Waste" — given as
     *                                 context so the model doesn't have to
     *                                 guess the domain from the image alone.
     * @param  string|null  $description  The citizen's own description, also
     *                                     passed as context.
     */
    public function assess(string $imageUrl, string $categoryName, ?string $description = null): AiSeverityResult;
}
