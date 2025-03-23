<?php
namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ToggleReminderRequest extends FormRequest
{
    public function authorize(): true
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'is_enabled' => 'required|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'is_enabled.required' => 'Статус включения обязателен.',
        ];
    }
}
