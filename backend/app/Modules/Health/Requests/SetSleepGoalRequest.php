<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetSleepGoalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'target_hours' => 'required|integer|between:5,12',
            'target_bedtime' => 'required|date_format:H:i',
            'target_wake_time' => 'required|date_format:H:i',
            'max_interruptions' => 'nullable|integer|min:0|max:10',
        ];
    }

    public function attributes(): array
    {
        return [
            'target_hours' => 'целевое количество часов сна',
            'target_bedtime' => 'целевое время отхода ко сну',
            'target_wake_time' => 'целевое время пробуждения',
            'max_interruptions' => 'максимальное количество прерываний',
        ];
    }

    public function messages(): array
    {
        return [
            'target_hours.between' => 'Целевое количество часов сна должно быть от 5 до 12 часов',
            'target_bedtime.date_format' => 'Время отхода ко сну должно быть в формате ЧЧ:ММ',
            'target_wake_time.date_format' => 'Время пробуждения должно быть в формате ЧЧ:ММ',
            'max_interruptions.min' => 'Максимальное количество прерываний не может быть отрицательным',
            'max_interruptions.max' => 'Максимальное количество прерываний не может быть больше 10',
        ];
    }
}
