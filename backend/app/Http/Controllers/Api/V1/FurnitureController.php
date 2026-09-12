<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\FurnitureResource;
use App\Services\FurnitureService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class FurnitureController extends Controller
{
    public function __construct(
        protected FurnitureService $furnitureService
    ) {}

    /**
     * Browse and search furniture catalog with dimensional and style filters.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $filters = $request->only([
            'category_id',
            'category_slug',
            'style',
            'material',
            'price_min',
            'price_max',
            'max_width_cm',
            'max_depth_cm',
            'max_height_cm',
            'max_width',
            'max_depth',
            'max_height',
            'search',
            'sort_by',
        ]);

        $perPage = (int) $request->input('per_page', 12);
        $perPage = min(max($perPage, 1), 50);

        $paginator = $this->furnitureService->list($filters, $perPage);

        return FurnitureResource::collection($paginator);
    }

    /**
     * Show single furniture item details with dimensional bounding boxes and 3D assets.
     */
    public function show(int $id): FurnitureResource
    {
        $furniture = $this->furnitureService->getById($id);

        if (!$furniture) {
            abort(404, 'Furniture item not found.');
        }

        return new FurnitureResource($furniture);
    }

    /**
     * Get featured furniture items for the landing page or quick-add shelf.
     */
    public function featured(): AnonymousResourceCollection
    {
        return FurnitureResource::collection($this->furnitureService->getFeatured(6));
    }

    /**
     * Get list of available furniture styles.
     */
    public function styles(): JsonResponse
    {
        return response()->json([
            'data' => $this->furnitureService->getStyles(),
        ]);
    }
}
