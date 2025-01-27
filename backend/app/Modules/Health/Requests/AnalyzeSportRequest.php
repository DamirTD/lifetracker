<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="AnalyzeSportRequest",
 *     required={"sport", "goal", "data"},
 *     @OA\Property(
 *         property="sport",
 *         type="string",
 *         enum={"Зал", "Бег", "Плавание", "Велоспорт"},
 *         description="Выбранный вид спорта"
 *     ),
 *     @OA\Property(
 *         property="goal",
 *         type="string",
 *         description="Цель занятий спортом"
 *     ),
 *     @OA\Property(
 *         property="data",
 *         type="object",
 *         description="Введенные параметры пользователя (например, вес, рост, время тренировки)"
 *     )
 * )
 */
class AnalyzeSportRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'sport' => ['required', 'string', 'in:Зал,Бег,Плавание,Велоспорт'],
            'goal'  => ['required', 'string']
        ];
    }

    public function messages(): array
    {
        return [
            'sport.required' => 'Выберите вид спорта.',
            'sport.exists'   => 'Выбранный вид спорта недействителен.',
            'goal.required'  => 'Укажите цель.',
        ];
    }
}
