<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetDailyGoalRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'weight'          => 'required|numeric|min:30|max:300',
            'height'          => 'required|numeric|min:100|max:250',
            'goal'            => 'required|string|in:maintain,lose_weight',
            'glass_volume_ml' => 'required|integer|min:50|max:1000',
        ];
    }

    public function messages(): array
    {
        return [
            'weight.required'          => 'Укажите ваш вес.',
            'weight.numeric'           => 'Вес должен быть числом.',
            'weight.min'               => 'Вес не может быть меньше 30 кг.',
            'weight.max'               => 'Вес не может превышать 300 кг.',

            'height.required'          => 'Укажите ваш рост.',
            'height.numeric'           => 'Рост должен быть числом.',
            'height.min'               => 'Рост не может быть меньше 100 см.',
            'height.max'               => 'Рост не может превышать 250 см.',

            'goal.required'            => 'Укажите вашу цель.',
            'goal.string'              => 'Цель должна быть строкой.',
            'goal.in'                  => 'Цель должна быть одной из следующих: maintain или lose_weight.',

            'glass_volume_ml.required' => 'Укажите объем стакана.',
            'glass_volume_ml.integer'  => 'Объем стакана должен быть целым числом.',
            'glass_volume_ml.min'      => 'Объем стакана не может быть меньше 50 мл.',
            'glass_volume_ml.max'      => 'Объем стакана не может превышать 1000 мл.',
        ];
    }
}
