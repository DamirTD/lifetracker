<?php

namespace App\Modules\Auth\Requests;
use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="LoginRequest",
 *     type="object",
 *     required={"login", "password"},
 *     @OA\Property(property="login", type="string", example="damir"),
 *     @OA\Property(property="password", type="string", example="password123")
 * )
 */
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
