<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\FurnitureResource;
use App\Models\Furniture;
use App\Models\RoomAnalysis;
use App\Models\RoomProject;
use App\Services\AIServiceClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AIController extends Controller
{
    protected AIServiceClient $aiClient;

    public function __construct(AIServiceClient $aiClient)
    {
        $this->aiClient = $aiClient;
    }

    /**
     * Upload and analyze a room photo via the AI microservice.
     */
    public function analyzeRoom(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|file|mimes:jpeg,png,jpg,webp|max:10240', // max 10MB
            'hint' => 'nullable|string|max:50',
            'room_project_id' => 'nullable|integer|exists:room_projects,id',
        ]);

        $file = $request->file('image');
        $storedPath = $file->store('analyses', 'public');

        // Call FastAPI microservice proxy
        $aiResult = $this->aiClient->analyzeRoom($file, $request->input('hint'));

        // Persist perception analysis to database
        $analysis = RoomAnalysis::create([
            'user_id' => $request->user()->id,
            'room_project_id' => $request->input('room_project_id'),
            'image_path' => $storedPath,
            'detected_room_type' => $aiResult['detected_room_type'] ?? null,
            'detected_style' => $aiResult['detected_style'] ?? null,
            'detected_colors' => $aiResult['dominant_colors'] ?? [],
            'detected_objects' => $aiResult['detected_objects'] ?? [],
            'confidence' => $aiResult['confidence'] ?? 0.85,
            'ai_provider' => $aiResult['provider'] ?? 'mock',
            'raw_response' => $aiResult,
        ]);

        return response()->json([
            'success' => true,
            'analysis' => [
                'id' => $analysis->id,
                'image_url' => Storage::url($storedPath),
                'detected_room_type' => $analysis->detected_room_type,
                'detected_style' => $analysis->detected_style,
                'dominant_colors' => $analysis->detected_colors ?? [],
                'detected_objects' => $analysis->detected_objects ?? [],
                'confidence' => $analysis->confidence,
                'visual_clutter' => $aiResult['visual_clutter'] ?? 'Low',
                'summary' => $aiResult['summary'] ?? null,
                'provider' => $analysis->ai_provider,
                'is_mock' => $aiResult['is_mock'] ?? false,
                'created_at' => $analysis->created_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * Get style-matched, geometry-constrained furniture recommendations.
     * Architectural Rule: AI suggests aesthetic affinity; Laravel strictly verifies physical bounds.
     */
    public function recommendations(Request $request): JsonResponse
    {
        $request->validate([
            'room_type' => 'nullable|string|max:50',
            'style' => 'nullable|string|max:50',
            'dominant_colors' => 'nullable|array',
            'room_project_id' => 'nullable|integer|exists:room_projects,id',
        ]);

        $roomProjectId = $request->input('room_project_id');
        $roomProject = null;
        $roomWidth = 400.0;
        $roomLength = 500.0;
        $existingFurnitureIds = [];

        if ($roomProjectId) {
            $roomProject = RoomProject::with('placements')->find($roomProjectId);
            if ($roomProject) {
                $roomWidth = (float) $roomProject->width_cm;
                $roomLength = (float) $roomProject->length_cm;
                $existingFurnitureIds = $roomProject->placements->pluck('furniture_id')->toArray();
            }
        }

        // Fetch curated active furniture catalog
        $catalogItems = Furniture::with(['category', 'primaryImage', 'model3d'])
            ->get()
            ->map(function ($f) {
                return [
                    'id' => $f->id,
                    'name' => $f->name,
                    'style' => $f->style,
                    'category_slug' => $f->category?->slug,
                    'price' => (float) $f->price,
                    'width_cm' => (float) ($f->width_cm ?? 100),
                    'depth_cm' => (float) ($f->depth_cm ?? 80),
                    'height_cm' => (float) ($f->height_cm ?? 75),
                ];
            })
            ->toArray();

        $payload = [
            'room_type' => $request->input('room_type', $roomProject?->room_type ?? 'Living Room'),
            'style' => $request->input('style', $roomProject?->style_preference ?? 'Scandinavian'),
            'dominant_colors' => $request->input('dominant_colors', []),
            'existing_furniture_ids' => $existingFurnitureIds,
            'room_dimensions' => [
                'width_cm' => $roomWidth,
                'length_cm' => $roomLength,
                'height_cm' => (float) ($roomProject?->height_cm ?? 280),
            ],
            'catalog' => $catalogItems,
        ];

        // 1. Solicit aesthetic recommendations from AI microservice
        $aiResult = $this->aiClient->recommend($payload);
        $rawRecs = $aiResult['recommendations'] ?? [];

        // 2. Authoritative Geometry & Catalog Filtering by Laravel
        $furnitureMap = Furniture::with(['category', 'primaryImage', 'model3d'])
            ->whereIn('id', array_column($rawRecs, 'furniture_id'))
            ->get()
            ->keyBy('id');

        $geometryConstrainedResults = [];

        foreach ($rawRecs as $rec) {
            $fId = $rec['furniture_id'] ?? null;
            if (!$fId || !isset($furnitureMap[$fId])) {
                continue;
            }

            $furniture = $furnitureMap[$fId];
            $itemW = (float) ($furniture->width_cm ?? 100);
            $itemD = (float) ($furniture->depth_cm ?? 80);

            // Verify basic physical room containment constraint (with rotation allowance)
            $fitsNormal = ($itemW <= $roomWidth && $itemD <= $roomLength);
            $fitsRotated = ($itemD <= $roomWidth && $itemW <= $roomLength);
            $fitsRoom = ($fitsNormal || $fitsRotated);

            if (!$fitsRoom) {
                // Reject items that cannot physically fit within room walls
                continue;
            }

            $geometryConstrainedResults[] = [
                'furniture' => (new FurnitureResource($furniture))->resolve($request),
                'score' => $rec['score'] ?? 0.85,
                'match_reasons' => $rec['match_reasons'] ?? ['Aesthetic style alignment'],
                'aesthetic_notes' => $rec['aesthetic_notes'] ?? null,
                'fits_room_bounds' => true,
            ];
        }

        return response()->json([
            'success' => true,
            'target_style' => $aiResult['target_style'] ?? $payload['style'],
            'target_palette' => $aiResult['target_palette'] ?? [],
            'provider' => $aiResult['provider'] ?? 'mock',
            'is_mock' => $aiResult['is_mock'] ?? false,
            'recommendations' => $geometryConstrainedResults,
        ]);
    }
}
