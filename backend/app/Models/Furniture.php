<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Furniture extends Model
{
    use HasFactory;

    protected $table = 'furniture';

    protected $fillable = [
        'category_id',
        'sku',
        'name',
        'description',
        'price',
        'width_cm',
        'height_cm',
        'depth_cm',
        'clearance_front_cm',
        'clearance_side_cm',
        'style',
        'material',
        'color',
        'color_hex',
        'glb_model_path',
        'is_active',
    ];

    protected $appends = [
        'width_m',
        'height_m',
        'depth_m',
        'bounding_box',
        'clearance_envelope',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'float',
            'width_cm' => 'float',
            'height_cm' => 'float',
            'depth_cm' => 'float',
            'clearance_front_cm' => 'float',
            'clearance_side_cm' => 'float',
            'is_active' => 'boolean',
        ];
    }

    /* -------------------------------------------------------------------------- */
    /*                         Normalized Spatial Accessors                       */
    /* -------------------------------------------------------------------------- */

    protected function widthM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->width_cm / 100, 4)
        );
    }

    protected function heightM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->height_cm / 100, 4)
        );
    }

    protected function depthM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->depth_cm / 100, 4)
        );
    }

    protected function footprintAreaSqm(): Attribute
    {
        return Attribute::make(
            get: fn () => round(($this->width_cm * $this->depth_cm) / 10000, 4)
        );
    }

    protected function boundingBox(): Attribute
    {
        return Attribute::make(
            get: fn () => [
                'width_m' => round($this->width_cm / 100, 4),
                'height_m' => round($this->height_cm / 100, 4),
                'depth_m' => round($this->depth_cm / 100, 4),
                'footprint_area_sqm' => round(($this->width_cm * $this->depth_cm) / 10000, 4),
            ]
        );
    }

    protected function clearanceEnvelope(): Attribute
    {
        return Attribute::make(
            get: fn () => [
                'front_m' => round($this->clearance_front_cm / 100, 4),
                'side_m' => round($this->clearance_side_cm / 100, 4),
                'total_width_m' => round(($this->width_cm + (2 * $this->clearance_side_cm)) / 100, 4),
                'total_depth_m' => round(($this->depth_cm + $this->clearance_front_cm) / 100, 4),
            ]
        );
    }

    protected function glbModelPath(): Attribute
    {
        return Attribute::make(
            get: function (?string $value) {
                if (!$value) {
                    return null;
                }
                $relativePath = ltrim(str_replace('/storage/', '', $value), '/');
                return \Illuminate\Support\Facades\Storage::disk('public')->exists($relativePath)
                    ? $value
                    : null;
            }
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                               Relationships                                */
    /* -------------------------------------------------------------------------- */

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function images(): HasMany
    {
        return $this->hasMany(FurnitureImage::class)->orderBy('sort_order');
    }

    public function primaryImage(): HasOne
    {
        return $this->hasOne(FurnitureImage::class)->where('is_primary', true);
    }

    public function models(): HasMany
    {
        return $this->hasMany(FurnitureModel::class);
    }

    public function activeModel(): HasOne
    {
        return $this->hasOne(FurnitureModel::class)->latestOfMany();
    }

    public function model3d(): HasOne
    {
        return $this->activeModel();
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    public function roomPlacements(): HasMany
    {
        return $this->hasMany(RoomProjectFurniture::class);
    }
}
