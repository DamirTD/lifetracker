<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="UserTrainingRequest",
 *     type="object",
 *     required={"sport_id", "goal", "name"},
 *     @OA\Property(
 *         property="sport_id",
 *         type="integer",
 *         example=2,
 *         description="ID спорта"
 *     ),
 *     @OA\Property(
 *         property="goal",
 *         type="string",
 *         example="Сбросить вес",
 *         description="Цель программы"
 *     ),
 *     @OA\Property(
 *         property="name",
 *         type="string",
 *         example="Утренняя зарядка",
 *         description="Название программы"
 *     ),
 *     @OA\Property(
 *         property="recommendation",
 *         type="string",
 *         example="Добавить больше кардио",
 *         description="Рекомендации (необязательное поле)"
 *     )
 * )
 */
class UserTrainingRequest extends FormRequest
{

    public function rules(): array
    {
        return [
            'sport_id'       => 'required|exists:sports,id',
            'goal'           => 'required|string',
            'name'           => 'required|string',
            'recommendation' => 'nullable|string',
            'sections'       => 'required|array|min:1|max:6',
            'sections.*.name' => 'required|string',
            'sections.*.exercises' => 'required|array|min:1|max:5',
            'sections.*.exercises.*.name' => 'required|string',
            'sections.*.exercises.*.reps' => 'required|integer|min:1',
            'sections.*.exercises.*.video_url' => 'nullable|url',
        ];
    }

    public function messages(): array
    {
        return [
            'sport_id.required'     => 'Поле "Спорт" обязательно для заполнения.',
            'sport_id.exists'       => 'Выбранный спорт не существует.',
            'goal.required'         => 'Поле "Цель" обязательно для заполнения.',
            'goal.string'           => 'Цель должна быть строкой.',
            'name.required'         => 'Поле "Название программы" обязательно для заполнения.',
            'name.string'           => 'Название программы должно быть строкой.',
            'recommendation.string' => 'Рекомендация должна быть строкой.',
        ];
    }
}
