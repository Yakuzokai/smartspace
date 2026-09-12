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
}
