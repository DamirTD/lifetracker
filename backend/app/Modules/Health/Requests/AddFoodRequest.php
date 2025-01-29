<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="AddFoodRequest",
 *     required={"food_id", "quantity", "date"},
 *     @OA\Property(property="food_id", type="integer", example=1),
 *     @OA\Property(property="quantity", type="number", example=200),
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29")
 * )
 */
class AddFoodRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'food_id'  => 'required|exists:foods,id',
            'quantity' => 'required|numeric',
            'date'     => 'required|date',
        ];
    }

    public function messages(): array
    {
        return [
            'food_id.required'  => 'Необходимо указать продукт.',
            'food_id.exists'    => 'Продукта с таким ID не существует.',
            'quantity.required' => 'Необходимо указать количество.',
            'quantity.numeric'  => 'Количество должно быть числом.',
            'date.required'     => 'Необходимо указать дату.',
            'date.date'         => 'Дата должна быть в формате YYYY-MM-DD.',
        ];
    }
}
