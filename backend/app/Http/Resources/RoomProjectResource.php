<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoomProjectResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'room_type' => $this->room_type,
            'style' => $this->style,
            'room_image_path' => $this->room_image_path,
            'dimensions' => [
                'width_cm' => (float) $this->width_cm,
                'length_cm' => (float) $this->length_cm,
                'height_cm' => (float) $this->height_cm,
                'width_m' => (float) $this->width_m,
                'length_m' => (float) $this->length_m,
                'height_m' => (float) $this->height_m,
                'floor_area_sqm' => (float) $this->floor_area_sqm,
            ],
            'compatibility_score' => $this->compatibility_score !== null ? (float) $this->compatibility_score : null,
            'score_breakdown' => $this->score_breakdown,
            'furniture_placements' => $this->furniturePlacements->map(function ($item) {
                $furniture = $item->furniture;
                return [
                    'id' => $item->id,
                    'furniture_id' => $item->furniture_id,
                    'sku' => $furniture?->sku,
                    'name' => $furniture?->name,
                    'category_slug' => $furniture?->category?->slug,
                    'dimensions' => [
                        'width_m' => (float) ($furniture?->width_m ?? 0),
                        'height_m' => (float) ($furniture?->height_m ?? 0),
                        'depth_m' => (float) ($furniture?->depth_m ?? 0),
                    ],
                    'model_path' => $furniture?->activeModel?->model_path ?? $furniture?->glb_model_path,
                    'position_x' => (float) $item->position_x,
                    'position_y' => (float) $item->position_y,
                    'position_z' => (float) $item->position_z,
                    'rotation_y' => (float) $item->rotation_y,
                    'scale' => 1.0, // Fixed physical scale
                    'world_bounds_2d' => $item->getWorldBounds2D(),
                ];
            }),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
