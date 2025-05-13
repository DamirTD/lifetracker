<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="CompleteTrainingRequest",
 *     type="object",
 *     required={"training_program_id", "duration", "calories_burned"},
 *     @OA\Property(
 *         property="training_program_id",
 *         type="integer",
 *         example=1,
 *         description="ID тренировочной программы"
 *     ),
 *     @OA\Property(
 *         property="duration",
 *         type="integer",
 *         example=60,
 *         description="Длительность тренировки в минутах"
 *     ),
 *     @OA\Property(
 *         property="calories_burned",
 *         type="integer",
 *         example=300,
 *         description="Количество потраченных калорий"
 *     )
 * )
 */
class CompleteTrainingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'training_program_id' => 'required|exists:user_training_programs,id',
            'duration'            => 'required|integer',
            'weight_before'       => 'nullable|numeric|min:0',
            'weight_after'        => 'nullable|numeric|min:0',
            'calories_burned'     => 'nullable|integer|min:0',
        ];
    }

    public function messages(): array
    {
        return [
            'training_program_id.required' => 'Поле "ID тренировочной программы" обязательно.',
            'duration.required'            => 'Поле "Длительность" обязательно.',
            'weight_before.numeric'        => 'Вес до тренировки должен быть числом.',
            'weight_after.numeric'         => 'Вес после тренировки должен быть числом.',
        ];
    }
}
