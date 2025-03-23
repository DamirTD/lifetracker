<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AddGlassRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'container_id' => 'nullable|integer|exists:user_water_containers,id',
            'volume_ml' => 'nullable|numeric|min:50|max:2000',
        ];
    }

    public function messages(): array
    {
        return [
            'container_id.exists' => 'Указанный контейнер не найден.',
            'volume_ml.min' => 'Объем должен быть не менее 50 мл.',
            'volume_ml.max' => 'Объем должен быть не более 2000 мл.',
        ];
    }
}
