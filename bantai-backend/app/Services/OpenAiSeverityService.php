<?php

namespace App\Services;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

/**
 * Reference AI provider using an OpenAI vision-capable model (e.g. gpt-4o).
 * Sends the uploaded photo's URL plus category/description context and asks
 * for a strict JSON response, which keeps parsing simple and reliable.
 *
 * Configure via .env:
 *   AI_SEVERITY_PROVIDER=openai
 *   OPENAI_API_KEY=sk-...
 *   OPENAI_SEVERITY_MODEL=gpt-4o-mini   (any vision-capable chat model works)
 */
class OpenAiSeverityService implements AiSeverityServiceInterface
{
    private Client $http;

    public function __construct(private readonly string $apiKey, private readonly string $model)
    {
        $this->http = new Client(['base_uri' => 'https://api.openai.com/v1/', 'timeout' => 20]);
    }

    public function assess(string $imageUrl, string $categoryName, ?string $description = null): AiSeverityResult
    {
        if (empty($this->apiKey)) {
            return AiSeverityResult::fallback('OPENAI_API_KEY is not set');
        }

        $prompt = <<<PROMPT
            You are assessing the severity of a civic infrastructure/environmental
            issue reported by a citizen, category "{$categoryName}", based only on
            the photo. Citizen's description: "{$description}".

            Respond with ONLY a JSON object, no other text, in this exact shape:
            {"severity": "Low|Moderate|High|Critical", "confidence": 0.0-1.0, "reasoning": "one short sentence"}

            Severity guide:
            - Low: cosmetic or minor, no real safety/health risk.
            - Moderate: a real inconvenience or minor hazard, not urgent.
            - High: a clear safety, health, or access hazard needing prompt attention.
            - Critical: an immediate danger to life, safety, or essential access.
            PROMPT;

        try {
            $response = $this->http->post('chat/completions', [
                'headers' => [
                    'Authorization' => "Bearer {$this->apiKey}",
                    'Content-Type' => 'application/json',
                ],
                'json' => [
                    'model' => $this->model,
                    'messages' => [[
                        'role' => 'user',
                        'content' => [
                            ['type' => 'text', 'text' => $prompt],
                            ['type' => 'image_url', 'image_url' => ['url' => $imageUrl]],
                        ],
                    ]],
                    'temperature' => 0,
                    'response_format' => ['type' => 'json_object'],
                ],
            ]);

            $body = json_decode((string) $response->getBody(), true);
            $content = $body['choices'][0]['message']['content'] ?? null;
            $parsed = $content ? json_decode($content, true) : null;

            $severity = ucfirst(strtolower($parsed['severity'] ?? ''));
            if (! in_array($severity, ['Low', 'Moderate', 'High', 'Critical'], true)) {
                return AiSeverityResult::fallback('unexpected model response');
            }

            return new AiSeverityResult(
                severity: $severity,
                confidence: (float) ($parsed['confidence'] ?? 0.5),
                reasoning: $parsed['reasoning'] ?? null,
            );
        } catch (\Throwable $e) {
            Log::warning('AI severity assessment failed', ['error' => $e->getMessage()]);

            return AiSeverityResult::fallback('provider request failed');
        }
    }
}
