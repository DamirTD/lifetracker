<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="RegisterRequest",
 *     type="object",
 *     required={"name", "surname", "login", "email", "password", "password_confirmation"},
 *     @OA\Property(property="name", type="string", example="Damir"),
 *     @OA\Property(property="surname", type="string", example="Toriya"),
 *     @OA\Property(property="login", type="string", example="damir"),
 *     @OA\Property(property="email", type="string", format="email", example="damir@example.com"),
 *     @OA\Property(property="password", type="string", format="password", example="password123"),
 *     @OA\Property(property="password_confirmation", type="string", format="password", example="password123")
 * )
 */
class RegisterRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name'     => 'required|string|max:255',
            'surname'  => 'required|string|max:255',
            'login'    => 'required|string|unique:users,login',
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

            'surname.required' => 'Поле "Фамилия" обязательно для заполнения.',
            'surname.string'   => 'Поле "Фамилия" должно быть строкой.',
            'surname.max'      => 'Поле "Фамилия" не должно превышать 255 символов.',

            'login.required' => 'Поле "Логин" обязательно для заполнения.',
            'login.unique'   => 'Этот логин уже зарегистрирован.',

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
