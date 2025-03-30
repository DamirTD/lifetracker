<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="AddFoodRequest",
 *     required={"food_id", "quantity", "date", "meal_type"},
 *     @OA\Property(property="food_id", type="integer", example=1),
 *     @OA\Property(property="quantity", type="number", example=200),
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29"),
 *     @OA\Property(property="meal_type", type="string", enum={"breakfast", "lunch", "dinner", "snack"}, example="breakfast")
 * )
 */
class AddFoodRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'food_id'   => 'required|exists:food,id',
            'quantity'  => 'required|numeric',
            'date'      => 'required|date',
            'meal_type' => 'required|in:breakfast,lunch,dinner,snack',
        ];
    }

    public function messages(): array
    {
        return [
            'food_id.required'   => 'Необходимо указать продукт.',
            'food_id.exists'     => 'Продукта с таким ID не существует.',
            'quantity.required'  => 'Необходимо указать количество.',
            'quantity.numeric'   => 'Количество должно быть числом.',
            'date.required'      => 'Необходимо указать дату.',
            'date.date'          => 'Дата должна быть в формате YYYY-MM-DD.',
            'meal_type.required' => 'Необходимо указать тип приема пищи.',
            'meal_type.in'       => 'Тип приема пищи должен быть одним из: завтрак, обед, ужин, перекус.',
        ];
    }
}
