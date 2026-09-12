<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateLayoutRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['present', 'array'],
            'items.*.furniture_id' => ['required', 'integer', 'exists:furniture,id'],
            'items.*.position_x' => ['required', 'numeric'],
            'items.*.position_y' => ['nullable', 'numeric'],
            'items.*.position_z' => ['required', 'numeric'],
            'items.*.rotation_y' => ['nullable', 'numeric'],
        ];
    }
}
