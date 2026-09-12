<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\RoomProjectRequest;
use App\Http\Requests\UpdateLayoutRequest;
use App\Http\Resources\RoomProjectResource;
use App\Models\RoomProject;
use App\Services\SpaceCompatibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;

class RoomProjectController extends Controller
{
    public function __construct(
        protected SpaceCompatibilityService $spaceService
    ) {}

    /**
     * List all room projects owned by the authenticated user.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $projects = $request->user()
            ->roomProjects()
            ->with(['furniturePlacements.furniture.category'])
            ->orderBy('updated_at', 'desc')
            ->get();

        return RoomProjectResource::collection($projects);
    }

    /**
     * Create a new room design project and run baseline spatial calculation.
     */
    public function store(RoomProjectRequest $request): JsonResponse
    {
        $project = $request->user()->roomProjects()->create($request->validated());

        // Run baseline spatial evaluation (empty room baseline = 100)
        $this->spaceService->evaluateProject($project, persist: true);

        $project->load('furniturePlacements.furniture.category');

        return (new RoomProjectResource($project))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * Show single room project with full 3D layout data.
     */
    public function show(int $id, Request $request): RoomProjectResource
    {
        $project = $request->user()
            ->roomProjects()
            ->with(['furniturePlacements.furniture.category', 'furniturePlacements.furniture.activeModel'])
            ->findOrFail($id);

        return new RoomProjectResource($project);
    }

    /**
     * Update room dimensions or architectural style metadata.
     */
    public function update(int $id, RoomProjectRequest $request): RoomProjectResource
    {
        $project = $request->user()->roomProjects()->findOrFail($id);

        $project->update($request->validated());

        // Re-evaluate geometry against new room dimensions
        $this->spaceService->evaluateProject($project, persist: true);
        $project->load('furniturePlacements.furniture.category');

        return new RoomProjectResource($project);
    }

    /**
     * Transactionally update the placed furniture layout in 3D space,
     * recalculating and persisting the certified compatibility score and breakdown.
     */
    public function updateLayout(int $id, UpdateLayoutRequest $request): RoomProjectResource
    {
        $project = $request->user()->roomProjects()->findOrFail($id);

        return DB::transaction(function () use ($project, $request) {
            // 1. Clear existing placements
            $project->furniturePlacements()->delete();

            // 2. Batch recreate new placements with locked physical scale
            $items = $request->validated('items');
            foreach ($items as $item) {
                $project->furniturePlacements()->create([
                    'furniture_id' => $item['furniture_id'],
                    'position_x' => (float) $item['position_x'],
                    'position_y' => (float) ($item['position_y'] ?? 0.0),
                    'position_z' => (float) $item['position_z'],
                    'rotation_y' => (float) ($item['rotation_y'] ?? 0.0),
                    'scale' => 1.0, // Scale locked to catalog physical truth
                ]);
            }

            // 3. Run authoritative geometry engine
            $this->spaceService->evaluateProject($project, persist: true);

            // 4. Return refreshed project
            $project->load(['furniturePlacements.furniture.category', 'furniturePlacements.furniture.activeModel']);

            return new RoomProjectResource($project);
        });
    }

    /**
     * Explicit on-demand spatial validation and certification endpoint.
     */
    public function validateLayout(int $id, Request $request): JsonResponse
    {
        $project = $request->user()->roomProjects()->findOrFail($id);

        $evaluation = $this->spaceService->evaluateProject($project, persist: true);

        return response()->json([
            'project_id' => $project->id,
            'evaluation' => $evaluation,
        ]);
    }

    /**
     * Delete a room project.
     */
    public function destroy(int $id, Request $request): JsonResponse
    {
        $project = $request->user()->roomProjects()->findOrFail($id);
        $project->delete();

        return response()->json([
            'message' => 'Room project deleted successfully.',
        ]);
    }
}
