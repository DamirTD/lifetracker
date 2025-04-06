<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="GetDietRequest",
 *     @OA\Property(property="meal_type", type="string", format="string", example="lunch")
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29")
 * )
 */
class GetDietRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'meal_type' => 'nullable|string|in:breakfast,lunch,dinner,snack',
            'date'      => 'nullable|date|date_format:Y-m-d',
        ];
    }
}
