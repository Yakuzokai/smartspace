<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    /**
     * Retrieve all root room categories with their child categories and furniture counts.
     */
    public function index(): JsonResponse
    {
        $categories = Category::whereNull('parent_id')
            ->where('is_active', true)
            ->with(['children' => function ($q) {
                $q->where('is_active', true)->withCount(['furniture' => function ($fq) {
                    $fq->where('is_active', true);
                }]);
            }])
            ->get();

        return response()->json([
            'data' => $categories->map(fn ($root) => [
                'id' => $root->id,
                'name' => $root->name,
                'slug' => $root->slug,
                'description' => $root->description,
                'icon' => $root->icon,
                'subcategories' => $root->children->map(fn ($child) => [
                    'id' => $child->id,
                    'name' => $child->name,
                    'slug' => $child->slug,
                    'description' => $child->description,
                    'icon' => $child->icon,
                    'furniture_count' => $child->furniture_count,
                ]),
            ]),
        ]);
    }

    /**
     * Retrieve a single category by ID or slug.
     */
    public function show(string|int $idOrSlug): JsonResponse
    {
        $category = Category::where('id', $idOrSlug)
            ->orWhere('slug', $idOrSlug)
            ->with(['parent', 'children' => fn ($q) => $q->withCount('furniture')])
            ->firstOrFail();

        return response()->json([
            'data' => [
                'id' => $category->id,
                'name' => $category->name,
                'slug' => $category->slug,
                'description' => $category->description,
                'icon' => $category->icon,
                'parent' => $category->parent ? [
                    'id' => $category->parent->id,
                    'name' => $category->parent->name,
                    'slug' => $category->parent->slug,
                ] : null,
                'children' => $category->children->map(fn ($child) => [
                    'id' => $child->id,
                    'name' => $child->name,
                    'slug' => $child->slug,
                    'furniture_count' => $child->furniture_count,
                ]),
            ],
        ]);
    }
}
