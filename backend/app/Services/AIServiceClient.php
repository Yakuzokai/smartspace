<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AIServiceClient
{
    protected string $baseUrl;
    protected string $apiKey;

    public function __construct()
    {
        $this->baseUrl = rtrim(config('services.ai_service.url', 'http://127.0.0.1:8001'), '/');
        $this->apiKey = config('services.ai_service.key', 'smartspace_internal_secret_key');
    }

    /**
     * Send room image to Python FastAPI microservice for vision perception.
     */
    public function analyzeRoom(UploadedFile|string $image, ?string $hint = null): array
    {
        $url = "{$this->baseUrl}/api/v1/analyze-room";

        try {
            $request = Http::timeout(12)
                ->withHeaders([
                    'X-Service-Key' => $this->apiKey,
                ]);

            if ($image instanceof UploadedFile) {
                $response = $request->attach(
                    'file',
                    fopen($image->getRealPath(), 'r'),
                    $image->getClientOriginalName()
                )->post($url, array_filter(['hint' => $hint]));
            } else {
                // $image is an absolute file path
                $response = $request->attach(
                    'file',
                    fopen($image, 'r'),
                    basename($image)
                )->post($url, array_filter(['hint' => $hint]));
            }

            if ($response->successful()) {
                return $response->json();
            }

            Log::warning("AI service returned non-200: {$response->status()} - {$response->body()}");
        } catch (\Throwable $e) {
            Log::error("Failed to communicate with AI microservice: {$e->getMessage()}");
        }

        // Resilient in-memory fallback if AI microservice is unreachable
        return [
            'detected_room_type' => $hint ?: 'Living Room',
            'detected_style' => 'Scandinavian',
            'dominant_colors' => ['#EAE6DF', '#173F35', '#D8B98A', '#252A27'],
            'detected_objects' => ['Natural Lighting', 'Hardwood Flooring', 'Perimeter Walls'],
            'visual_clutter' => 'Low',
            'confidence' => 0.90,
            'provider' => 'mock',
            'is_mock' => true,
            'summary' => 'Fallback demonstration perception: Harmonious Scandinavian layout with organic light balance.',
        ];
    }

    /**
     * Send aesthetic matching request to Python FastAPI microservice.
     */
    public function recommend(array $payload): array
    {
        $url = "{$this->baseUrl}/api/v1/recommendations";

        try {
            $response = Http::timeout(10)
                ->withHeaders([
                    'X-Service-Key' => $this->apiKey,
                ])
                ->post($url, $payload);

            if ($response->successful()) {
                return $response->json();
            }

            Log::warning("AI recommendations returned non-200: {$response->status()} - {$response->body()}");
        } catch (\Throwable $e) {
            Log::error("Failed to fetch AI recommendations: {$e->getMessage()}");
        }

        // Fallback recommendations if microservice is down
        return [
            'recommendations' => [],
            'target_style' => $payload['style'] ?? 'Scandinavian',
            'target_palette' => $payload['dominant_colors'] ?? ['#EAE6DF', '#173F35'],
            'provider' => 'mock',
            'is_mock' => true,
        ];
    }

    /**
     * Check health and measure roundtrip latency to FastAPI microservice.
     */
    public function checkHealth(): array
    {
        $url = "{$this->baseUrl}/api/v1/health";
        $startTime = microtime(true);

        try {
            $response = Http::timeout(3)->get($url);
            $latencyMs = round((microtime(true) - $startTime) * 1000, 2);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'status' => 'operational',
                    'available' => true,
                    'latency_ms' => $latencyMs,
                    'active_provider' => $data['active_provider'] ?? 'gemini',
                    'gemini_configured' => (bool) ($data['gemini_configured'] ?? false),
                    'service_name' => $data['service'] ?? 'SmartSpace AI Microservice',
                ];
            }

            return [
                'status' => 'degraded',
                'available' => false,
                'latency_ms' => $latencyMs,
                'active_provider' => 'none',
                'error' => "HTTP {$response->status()}",
            ];
        } catch (\Throwable $e) {
            $latencyMs = round((microtime(true) - $startTime) * 1000, 2);
            return [
                'status' => 'offline',
                'available' => false,
                'latency_ms' => $latencyMs,
                'active_provider' => 'none',
                'error' => 'Connection refused / service unreachable',
            ];
        }
    }
}
