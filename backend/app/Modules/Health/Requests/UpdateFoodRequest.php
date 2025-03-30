<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="UpdateFoodRequest",
 *     @OA\Property(property="quantity", type="number", example=150),
 *     @OA\Property(property="meal_type", type="string", enum={"breakfast", "lunch", "dinner", "snack"}, example="lunch")
 * )
 */
class UpdateFoodRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'quantity'  => 'sometimes|numeric',
            'meal_type' => 'sometimes|in:breakfast,lunch,dinner,snack',
        ];
    }

    public function messages(): array
    {
        return [
            'quantity.numeric' => 'Количество должно быть числом.',
            'meal_type.in'     => 'Тип приема пищи должен быть одним из: завтрак, обед, ужин, перекус.',
        ];
    }
}
