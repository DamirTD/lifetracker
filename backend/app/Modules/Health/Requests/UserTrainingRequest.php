<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;


/**
 * @OA\Schema(
 *     schema="UserTrainingRequest",
 *     type="object",
 *     required={"sport_id", "goal", "name", "sections"},
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
 *     ),
 *     @OA\Property(
 *         property="sections",
 *         type="array",
 *         minItems=1,
 *         maxItems=6,
 *         description="Секции тренировочной программы",
 *         @OA\Items(
 *             type="object",
 *             required={"name", "exercises"},
 *             @OA\Property(
 *                 property="name",
 *                 type="string",
 *                 example="Грудь + трицепс",
 *                 description="Название секции"
 *             ),
 *             @OA\Property(
 *                 property="exercises",
 *                 type="array",
 *                 minItems=1,
 *                 maxItems=5,
 *                 description="Список упражнений",
 *                 @OA\Items(
 *                     type="object",
 *                     required={"name", "reps"},
 *                     @OA\Property(
 *                         property="name",
 *                         type="string",
 *                         example="Жим лёжа",
 *                         description="Название упражнения"
 *                     ),
 *                     @OA\Property(
 *                         property="reps",
 *                         type="integer",
 *                         example=10,
 *                         description="Количество повторений"
 *                     ),
 *                     @OA\Property(
 *                         property="video_url",
 *                         type="string",
 *                         format="url",
 *                         nullable=true,
 *                         example="https://youtube.com/example",
 *                         description="Ссылка на видео с упражнением (необязательно)"
 *                     )
 *                 )
 *             )
 *         )
 *     )
 * )
 */
class UserTrainingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'sport_id'                         => 'required|exists:sports,id',
            'goal'                             => 'required|string',
            'name'                             => 'required|string',
            'recommendation'                   => 'nullable|string',
            'sections'                         => 'required|array|min:1|max:6',
            'sections.*.name'                  => 'required|string',
            'sections.*.exercises'             => 'required|array|min:1|max:5',
            'sections.*.exercises.*.name'      => 'required|string',
            'sections.*.exercises.*.reps'      => 'required|integer|min:1',
            'sections.*.exercises.*.video_url' => 'nullable|string',
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
