<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\FurnitureResource;
use App\Models\Favorite;
use App\Models\Furniture;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class FavoriteController extends Controller
{
    /**
     * List all furniture items favorited by the authenticated user.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $favorites = $request->user()
            ->favorites()
            ->with(['furniture.category', 'furniture.primaryImage', 'furniture.activeModel'])
            ->get();

        $furnitureList = $favorites->pluck('furniture')->filter();

        return FurnitureResource::collection($furnitureList);
    }

    /**
     * Toggle favorite status for a given furniture item.
     */
    public function toggle(int $furnitureId, Request $request): JsonResponse
    {
        // Verify furniture exists
        Furniture::findOrFail($furnitureId);

        $existing = Favorite::where('user_id', $request->user()->id)
            ->where('furniture_id', $furnitureId)
            ->first();

        if ($existing) {
            $existing->delete();
            return response()->json([
                'favorited' => false,
                'message' => 'Furniture removed from favorites.',
            ]);
        }

        Favorite::create([
            'user_id' => $request->user()->id,
            'furniture_id' => $furnitureId,
            'created_at' => now(),
        ]);

        return response()->json([
            'favorited' => true,
            'message' => 'Furniture added to favorites.',
        ]);
    }
}
