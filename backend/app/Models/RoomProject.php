<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RoomProject extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'room_type',
        'width_cm',
        'length_cm',
        'height_cm',
        'style',
        'room_image_path',
        'compatibility_score',
        'score_breakdown',
    ];

    protected $appends = [
        'width_m',
        'length_m',
        'height_m',
        'floor_area_sqm',
    ];

    protected function casts(): array
    {
        return [
            'width_cm' => 'float',
            'length_cm' => 'float',
            'height_cm' => 'float',
            'compatibility_score' => 'float',
            'score_breakdown' => 'array',
        ];
    }

    protected function widthM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->width_cm / 100, 4)
        );
    }

    protected function lengthM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->length_cm / 100, 4)
        );
    }

    protected function heightM(): Attribute
    {
        return Attribute::make(
            get: fn () => round($this->height_cm / 100, 4)
        );
    }

    protected function floorAreaSqm(): Attribute
    {
        return Attribute::make(
            get: fn () => round(($this->width_cm * $this->length_cm) / 10000, 4)
        );
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function furniturePlacements(): HasMany
    {
        return $this->hasMany(RoomProjectFurniture::class);
    }

    public function roomAnalyses(): HasMany
    {
        return $this->hasMany(RoomAnalysis::class);
    }
}
