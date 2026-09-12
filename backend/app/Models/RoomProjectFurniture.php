<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomProjectFurniture extends Model
{
    use HasFactory;

    protected $table = 'room_project_furniture';

    protected $fillable = [
        'room_project_id',
        'furniture_id',
        'position_x',
        'position_y',
        'position_z',
        'rotation_y',
        'scale',
    ];

    protected $attributes = [
        'scale' => 1.000,
    ];

    protected function casts(): array
    {
        return [
            'position_x' => 'float',
            'position_y' => 'float',
            'position_z' => 'float',
            'rotation_y' => 'float',
            'scale' => 'float',
        ];
    }

    public function roomProject(): BelongsTo
    {
        return $this->belongsTo(RoomProject::class);
    }

    public function furniture(): BelongsTo
    {
        return $this->belongsTo(Furniture::class);
    }

    /**
     * Compute world-space 2D bounding extents (minX, maxX, minZ, maxZ in meters)
     * using physical catalog dimensions (fixed physical scale).
     */
    public function getWorldBounds2D(): array
    {
        $w = $this->furniture?->width_m ?? 0.0;
        $d = $this->furniture?->depth_m ?? 0.0;
        $rad = deg2rad($this->rotation_y);

        $halfW = $w / 2;
        $halfD = $d / 2;

        $corners = [
            [-$halfW, -$halfD],
            [$halfW, -$halfD],
            [$halfW, $halfD],
            [-$halfW, $halfD],
        ];

        $minX = INF;
        $maxX = -INF;
        $minZ = INF;
        $maxZ = -INF;

        foreach ($corners as [$cx, $cz]) {
            $rx = $cx * cos($rad) - $cz * sin($rad);
            $rz = $cx * sin($rad) + $cz * cos($rad);

            $worldX = $this->position_x + $rx;
            $worldZ = $this->position_z + $rz;

            $minX = min($minX, $worldX);
            $maxX = max($maxX, $worldX);
            $minZ = min($minZ, $worldZ);
            $maxZ = max($maxZ, $worldZ);
        }

        return [
            'min_x' => round($minX, 4),
            'max_x' => round($maxX, 4),
            'min_z' => round($minZ, 4),
            'max_z' => round($maxZ, 4),
            'center_x' => round($this->position_x, 4),
            'center_z' => round($this->position_z, 4),
        ];
    }
}
