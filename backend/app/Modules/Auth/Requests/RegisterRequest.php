<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{

    public function rules(): array
    {
        return [
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Поле "Имя" обязательно для заполнения.',
            'name.string'   => 'Поле "Имя" должно быть строкой.',
            'name.max'      => 'Поле "Имя" не должно превышать 255 символов.',

            'email.required' => 'Поле "Email" обязательно для заполнения.',
            'email.email'    => 'Поле "Email" должно быть корректным email-адресом.',
            'email.unique'   => 'Этот email уже зарегистрирован.',

            'password.required'  => 'Поле "Пароль" обязательно для заполнения.',
            'password.string'    => 'Поле "Пароль" должно быть строкой.',
            'password.min'       => 'Пароль должен содержать минимум 8 символов.',
            'password.confirmed' => 'Пароли не совпадают.',
        ];
    }
}
