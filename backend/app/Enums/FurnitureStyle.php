<?php

namespace App\Enums;

enum FurnitureStyle: string
{
    case Minimalist = 'minimalist';
    case Modern = 'modern';
    case Scandinavian = 'scandinavian';
    case Industrial = 'industrial';
    case Classic = 'classic';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
