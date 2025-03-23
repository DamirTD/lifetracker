<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetDailyGoalRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'weight' => 'required|numeric|min:30|max:250',
            'height' => 'required|numeric|min:100|max:250',
            'goal' => 'nullable|string|in:maintain_weight,lose_weight,gain_muscle',
            'glass_volume_ml' => 'required|numeric|min:100|max:1000',
            'activity_level' => 'nullable|string|in:sedentary,moderate,active,very_active',
            'climate' => 'nullable|string|in:cold,moderate,hot,very_hot',
        ];
    }

    public function messages(): array
    {
        return [
            'weight.required' => 'Вес обязателен для расчета нормы воды.',
            'height.required' => 'Рост обязателен для расчета нормы воды.',
            'goal.required' => 'Цель обязательна для расчета нормы воды.',
            'glass_volume_ml.required' => 'Объем стакана обязателен.',
        ];
    }
}
