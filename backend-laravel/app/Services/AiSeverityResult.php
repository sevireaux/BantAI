<?php

namespace App\Services;

final class AiSeverityResult
{
    public function __construct(
        public readonly string $severity,          // Low | Moderate | High | Critical
        public readonly float $confidence,         // 0.0–1.0
        public readonly ?string $reasoning = null, // short human-readable explanation, if the provider gives one
    ) {}

    public static function fallback(string $reason): self
    {
        // If the AI call fails or isn't configured, default to Moderate
        // rather than silently under- or over-prioritizing — an LGU
        // Official still reviews every Pending report regardless.
        return new self('Moderate', 0.0, "AI assessment unavailable ({$reason}); defaulted to Moderate pending human review.");
    }
}
