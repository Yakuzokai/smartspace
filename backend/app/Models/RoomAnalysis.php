<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomAnalysis extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'room_project_id',
        'image_path',
        'detected_room_type',
        'detected_style',
        'detected_colors',
        'detected_objects',
        'confidence',
        'ai_provider',
        'raw_response',
    ];

    /**
     * Keep raw AI vendor payload private from frontend consumers.
     */
    protected $hidden = [
        'raw_response',
    ];

    protected function casts(): array
    {
        return [
            'detected_colors' => 'array',
            'detected_objects' => 'array',
            'raw_response' => 'array',
            'confidence' => 'float',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function roomProject(): BelongsTo
    {
        return $this->belongsTo(RoomProject::class);
    }
}
