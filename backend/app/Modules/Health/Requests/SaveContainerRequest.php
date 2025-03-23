<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SaveContainerRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id' => 'nullable|integer|exists:user_water_containers,id',
            'name' => 'required|string|max:100',
            'volume_ml' => 'required|numeric|min:50|max:2000',
            'icon' => 'nullable|string|max:50',
            'color' => 'nullable|string|max:20',
            'is_default' => 'nullable|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Название контейнера обязательно.',
            'volume_ml.required' => 'Объем контейнера обязателен.',
            'id.exists' => 'Указанный контейнер не найден.',
        ];
    }
}
