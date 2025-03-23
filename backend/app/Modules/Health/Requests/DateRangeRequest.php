<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DateRangeRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'start_date' => 'nullable|date_format:Y-m-d',
            'end_date' => 'nullable|date_format:Y-m-d|after_or_equal:start_date',
        ];
    }

    public function messages(): array
    {
        return [
            'start_date.date_format' => 'Неверный формат начальной даты. Используйте YYYY-MM-DD.',
            'end_date.date_format' => 'Неверный формат конечной даты. Используйте YYYY-MM-DD.',
            'end_date.after_or_equal' => 'Конечная дата должна быть не раньше начальной.',
        ];
    }
}
