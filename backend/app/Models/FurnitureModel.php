<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FurnitureModel extends Model
{
    use HasFactory;

    protected $fillable = [
        'furniture_id',
        'model_path',
        'format',
        'file_size_mb',
        'is_optimized',
        'draco_compressed',
    ];

    protected function casts(): array
    {
        return [
            'file_size_mb' => 'float',
            'is_optimized' => 'boolean',
            'draco_compressed' => 'boolean',
        ];
    }

    public function furniture(): BelongsTo
    {
        return $this->belongsTo(Furniture::class);
    }

    protected function modelPath(): \Illuminate\Database\Eloquent\Casts\Attribute
    {
        return \Illuminate\Database\Eloquent\Casts\Attribute::make(
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
}
