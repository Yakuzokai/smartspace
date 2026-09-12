<?php

namespace App\Enums;

enum RoomType: string
{
    case LivingRoom = 'living_room';
    case Bedroom = 'bedroom';
    case HomeOffice = 'home_office';
    case DiningRoom = 'dining_room';
    case Studio = 'studio';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
