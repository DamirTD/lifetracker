<?php
namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MonthYearRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'year_month' => 'nullable|date_format:Y-m',
        ];
    }

    public function messages(): array
    {
        return [
            'year_month.date_format' => 'Неверный формат даты. Используйте YYYY-MM.',
        ];
    }
}
