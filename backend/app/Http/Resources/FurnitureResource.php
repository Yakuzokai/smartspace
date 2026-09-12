<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FurnitureResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $user = $request->user('sanctum');

        return [
            'id' => $this->id,
            'sku' => $this->sku,
            'name' => $this->name,
            'description' => $this->description,
            'price' => (float) $this->price,
            'dimensions' => [
                'width_cm' => (float) $this->width_cm,
                'height_cm' => (float) $this->height_cm,
                'depth_cm' => (float) $this->depth_cm,
                'width_m' => (float) $this->width_m,
                'height_m' => (float) $this->height_m,
                'depth_m' => (float) $this->depth_m,
                'footprint_area_sqm' => (float) $this->footprint_area_sqm,
            ],
            'bounding_box' => $this->bounding_box,
            'clearance_envelope' => $this->clearance_envelope,
            'style' => $this->style,
            'material' => $this->material,
            'color' => $this->color,
            'color_hex' => $this->color_hex,
            'primary_image' => $this->primaryImage?->image_path ?? $this->images->first()?->image_path,
            'images' => $this->images->map(fn ($img) => [
                'id' => $img->id,
                'image_path' => $img->image_path,
                'is_primary' => (bool) $img->is_primary,
            ]),
            'model_3d' => [
                'path' => $this->activeModel?->model_path ?? $this->glb_model_path,
                'format' => $this->activeModel?->format ?? 'glb',
                'file_size_mb' => (float) ($this->activeModel?->file_size_mb ?? 0.0),
                'draco_compressed' => (bool) ($this->activeModel?->draco_compressed ?? true),
            ],
            'category' => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
                'slug' => $this->category?->slug,
                'parent' => $this->category?->parent ? [
                    'id' => $this->category->parent->id,
                    'name' => $this->category->parent->name,
                    'slug' => $this->category->parent->slug,
                ] : null,
            ],
            // Future-compatible inventory structure
            'availability' => [
                'status' => 'in_stock',
                'quantity' => 10,
            ],
            'is_favorite' => $user ? $this->favorites()->where('user_id', $user->id)->exists() : false,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
