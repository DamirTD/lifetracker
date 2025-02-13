<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'goal' => 'required|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Название обязательно для заполнения.',
            'name.string'   => 'Название должно быть строкой.',
            'name.max'      => 'Название не должно превышать 255 символов.',
            'goal.required' => 'Цель обязательна для заполнения.',
            'goal.string'   => 'Цель должна быть строкой.',
            'goal.max'      => 'Цель не должна превышать 255 символов.',
        ];
    }
}
