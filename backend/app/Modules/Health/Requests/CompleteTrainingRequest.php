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
            'calories_burned'     => 'required|integer',
        ];
    }

    public function messages(): array
    {
        return [
            'training_program_id.required' => 'Поле "ID тренировочной программы" обязательно для заполнения.',
            'training_program_id.exists'   => 'Выбранная тренировочная программа не существует.',
            'duration.required'            => 'Поле "Длительность тренировки" обязательно для заполнения.',
            'duration.integer'             => 'Длительность тренировки должна быть целым числом.',
            'calories_burned.required'     => 'Поле "Потраченные калории" обязательно для заполнения.',
            'calories_burned.integer'      => 'Количество потраченных калорий должно быть целым числом.',
        ];
    }
}
