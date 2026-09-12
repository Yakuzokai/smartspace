<?php

namespace App\Http\Requests;

use App\Enums\FurnitureStyle;
use App\Enums\RoomType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RoomProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'room_type' => ['required', 'string', Rule::in(RoomType::values())],
            'width_cm' => ['required', 'numeric', 'min:150', 'max:2000'],
            'length_cm' => ['required', 'numeric', 'min:150', 'max:2000'],
            'height_cm' => ['nullable', 'numeric', 'min:200', 'max:500'],
            'style' => ['nullable', 'string', Rule::in(FurnitureStyle::values())],
        ];
    }
}
