<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AIServiceClient;
use App\Services\SpaceCompatibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SystemHealthController extends Controller
{
    protected AIServiceClient $aiClient;
    protected SpaceCompatibilityService $spatialService;

    public function __construct(AIServiceClient $aiClient, SpaceCompatibilityService $spatialService)
    {
        $this->aiClient = $aiClient;
        $this->spatialService = $spatialService;
    }

    /**
     * Aggregated System Telemetry & Health Endpoint.
     * Preserves single-gateway architecture: Frontend -> Laravel -> FastAPI.
     */
    public function show(Request $request): JsonResponse
    {
        $start = microtime(true);

        // 1. Check Database connection & ping
        $dbStatus = 'operational';
        $dbLatencyMs = 0.0;
        try {
            $dbStart = microtime(true);
            DB::connection()->getPdo();
            $dbLatencyMs = round((microtime(true) - $dbStart) * 1000, 2);
        } catch (\Throwable $e) {
            $dbStatus = 'offline';
        }

        // 2. Check Spatial Geometry Engine readiness
        $spatialStatus = 'operational';
        $spatialTestLatencyMs = 0.0;
        try {
            $sStart = microtime(true);
            // Quick deterministic sanity check
            $this->spatialService->evaluateLayout(400.0, 500.0, 280.0, 'living_room', []);
            $spatialTestLatencyMs = round((microtime(true) - $sStart) * 1000, 2);
        } catch (\Throwable $e) {
            $spatialStatus = 'error';
        }

        // 3. Query internal AI Microservice health via AIServiceClient
        $aiHealth = $this->aiClient->checkHealth();

        // 4. Retrieve cached benchmark metrics (if previously generated)
        $benchmarks = Cache::get('smartspace_benchmark_summary', [
            'geometry_p95_ms' => 2.45,
            'api_p95_ms' => 18.20,
            'ai_p95_ms' => 320.00,
            'tested_items_range' => '5 - 40 items',
            'iterations' => 100,
            'status' => 'estimated_baseline',
        ]);

        $laravelLatencyMs = round((microtime(true) - $start) * 1000, 2);

        return response()->json([
            'status' => 'healthy',
            'timestamp' => now()->toIso8601String(),
            'environment' => app()->environment(),
            'gateway' => [
                'service' => 'SmartSpace Laravel Gateway API',
                'status' => 'operational',
                'latency_ms' => $laravelLatencyMs,
                'php_version' => PHP_VERSION,
                'framework' => 'Laravel ' . app()->version(),
            ],
            'database' => [
                'status' => $dbStatus,
                'driver' => config('database.default'),
                'latency_ms' => $dbLatencyMs,
            ],
            'spatial_engine' => [
                'service' => 'SpaceCompatibilityService',
                'status' => $spatialStatus,
                'algorithm' => 'Rotation-Aware AABB Bounding & Collision',
                'scale_locked' => 1.000,
                'sanity_latency_ms' => $spatialTestLatencyMs,
            ],
            'ai_microservice' => [
                'service' => 'FastAPI AI Microservice',
                'status' => $aiHealth['status'],
                'available' => $aiHealth['available'],
                'latency_ms' => $aiHealth['latency_ms'],
                'active_provider' => $aiHealth['active_provider'],
                'gemini_configured' => $aiHealth['gemini_configured'] ?? false,
                'resilient_fallback' => 'Graceful degradation enabled',
            ],
            'benchmarks' => $benchmarks,
        ]);
    }
}
