<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="GetDietRequest",
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29")
 * )
 */
class GetDietRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'date' => 'nullable|date',
        ];
    }

    public function messages(): array
    {
        return [
            'date.date' => 'Дата должна быть в формате YYYY-MM-DD.',
        ];
    }
}
