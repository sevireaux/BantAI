<?php

namespace App\Providers;

use App\Services\AiSeverityServiceInterface;
use App\Services\NullSeverityService;
use App\Services\OpenAiSeverityService;
use Illuminate\Support\ServiceProvider;

class AiSeverityServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(AiSeverityServiceInterface::class, function () {
            return match (config('services.ai_severity.provider', 'none')) {
                'openai' => new OpenAiSeverityService(
                    apiKey: (string) config('services.openai.key'),
                    model: (string) config('services.openai.severity_model', 'gpt-4o-mini'),
                ),
                // Add more providers here as needed, e.g.:
                // 'google_vision' => app(GoogleVisionSeverityService::class),
                default => new NullSeverityService(),
            };
        });
    }
}
