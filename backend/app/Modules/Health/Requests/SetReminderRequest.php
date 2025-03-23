<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetReminderRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id' => 'nullable|integer|exists:user_water_reminders,id',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'interval_minutes' => 'required|integer|min:15|max:240',
            'days_of_week' => 'nullable|array',
            'days_of_week.*' => 'integer|between:1,7',
            'is_enabled' => 'nullable|boolean',
            'message' => 'nullable|string|max:200',
        ];
    }

    public function messages(): array
    {
        return [
            'start_time.required' => 'Время начала напоминаний обязательно.',
            'end_time.required' => 'Время окончания напоминаний обязательно.',
            'end_time.after' => 'Время окончания должно быть позже времени начала.',
            'interval_minutes.required' => 'Интервал напоминаний обязателен.',
            'interval_minutes.min' => 'Интервал должен быть не менее 15 минут.',
            'interval_minutes.max' => 'Интервал должен быть не более 4 часов.',
            'id.exists' => 'Указанное напоминание не найдено.',
            'days_of_week.*.between' => 'Дни недели должны быть числами от 1 до 7.',
        ];
    }
}
