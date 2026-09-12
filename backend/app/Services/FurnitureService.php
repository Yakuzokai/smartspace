<?php

namespace App\Services;

use App\Enums\FurnitureStyle;
use App\Models\Category;
use App\Models\Furniture;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;

class FurnitureService
{
    /**
     * Retrieve paginated furniture items with multidimensional filters.
     *
     * @param array $filters
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function list(array $filters = [], int $perPage = 12): LengthAwarePaginator
    {
        $query = Furniture::query()
            ->where('is_active', true)
            ->with(['category', 'primaryImage', 'activeModel']);

        // 1. Filter by Category ID or Category Slug (including parent/child traversal)
        if (!empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        } elseif (!empty($filters['category_slug'])) {
            $slug = $filters['category_slug'];
            $category = Category::where('slug', $slug)->with('children')->first();

            if ($category) {
                if ($category->children->isNotEmpty()) {
                    // Parent category selected -> include all child category items
                    $catIds = $category->children->pluck('id')->push($category->id)->all();
                    $query->whereIn('category_id', $catIds);
                } else {
                    $query->where('category_id', $category->id);
                }
            } else {
                $query->whereRaw('0 = 1'); // Slug doesn't exist
            }
        }

        // 2. Filter by Interior Style
        if (!empty($filters['style'])) {
            $query->where('style', $filters['style']);
        }

        // 3. Filter by Material
        if (!empty($filters['material'])) {
            $query->where('material', 'LIKE', '%' . $filters['material'] . '%');
        }

        // 4. Filter by Price Range
        if (isset($filters['price_min']) && is_numeric($filters['price_min'])) {
            $query->where('price', '>=', (float) $filters['price_min']);
        }
        if (isset($filters['price_max']) && is_numeric($filters['price_max'])) {
            $query->where('price', '<=', (float) $filters['price_max']);
        }

        // 5. Geometry / Physical Dimension Constraints (in cm)
        $maxWidth = $filters['max_width_cm'] ?? $filters['max_width'] ?? null;
        if ($maxWidth !== null && is_numeric($maxWidth)) {
            $query->where('width_cm', '<=', (float) $maxWidth);
        }

        $maxDepth = $filters['max_depth_cm'] ?? $filters['max_depth'] ?? null;
        if ($maxDepth !== null && is_numeric($maxDepth)) {
            $query->where('depth_cm', '<=', (float) $maxDepth);
        }

        $maxHeight = $filters['max_height_cm'] ?? $filters['max_height'] ?? null;
        if ($maxHeight !== null && is_numeric($maxHeight)) {
            $query->where('height_cm', '<=', (float) $maxHeight);
        }

        // 6. Free-text Search (Name, SKU, Description, Material, Color)
        if (!empty($filters['search'])) {
            $term = trim($filters['search']);
            $query->where(function (Builder $q) use ($term) {
                $q->where('name', 'LIKE', "%{$term}%")
                    ->orWhere('sku', 'LIKE', "%{$term}%")
                    ->orWhere('description', 'LIKE', "%{$term}%")
                    ->orWhere('material', 'LIKE', "%{$term}%")
                    ->orWhere('color', 'LIKE', "%{$term}%");
            });
        }

        // 7. Sorting
        $sortBy = $filters['sort_by'] ?? 'newest';
        match ($sortBy) {
            'price_asc' => $query->orderBy('price', 'asc'),
            'price_desc' => $query->orderBy('price', 'desc'),
            'width_asc' => $query->orderBy('width_cm', 'asc'),
            'width_desc' => $query->orderBy('width_cm', 'desc'),
            'name_asc' => $query->orderBy('name', 'asc'),
            default => $query->orderBy('id', 'desc'),
        };

        return $query->paginate($perPage);
    }

    /**
     * Retrieve single furniture item with eager-loaded relations.
     *
     * @param int $id
     * @return Furniture|null
     */
    public function getById(int $id): ?Furniture
    {
        return Furniture::where('is_active', true)
            ->with(['category.parent', 'images', 'models'])
            ->find($id);
    }

    /**
     * Retrieve featured furniture items for the homepage showcase.
     *
     * @param int $limit
     * @return Collection
     */
    public function getFeatured(int $limit = 6): Collection
    {
        return Furniture::where('is_active', true)
            ->with(['category', 'primaryImage', 'activeModel'])
            ->inRandomOrder()
            ->limit($limit)
            ->get();
    }

    /**
     * Get list of supported furniture styles.
     *
     * @return array
     */
    public function getStyles(): array
    {
        return FurnitureStyle::values();
    }
}
