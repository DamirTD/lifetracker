<?php

namespace App\Modules\Auth\Requests;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'login'    => 'required|string',
            'password' => 'required|string',
        ];
    }

    public function messages(): array
    {
        return [
            'login.required'    => 'Логин обязателен.',
            'password.required' => 'Пароль обязателен.',
        ];
    }
}
