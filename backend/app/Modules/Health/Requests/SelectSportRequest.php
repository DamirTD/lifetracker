<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;


/**
 * @OA\Schema(
 *     schema="SelectSportRequest",
 *     required={"sport_id", "goal"},
 *     @OA\Property(
 *         property="sport_id",
 *         type="integer",
 *         description="ID выбранного вида спорта",
 *         example=1
 *     ),
 *     @OA\Property(
 *         property="goal",
 *         type="string",
 *         description="Цель занятий спортом",
 *         example="похудеть"
 *     )
 * )
 */
class SelectSportRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'sport_id' => ['required', 'integer', 'exists:sports,id'],
            'goal'     => ['required', 'string']
        ];
    }

    public function messages(): array
    {
        return [
            'sport_id.required' => 'Выберите вид спорта.',
            'sport_id.integer'  => 'ID спорта должен быть числом.',
            'sport_id.exists'   => 'Выбранный вид спорта недействителен.',
            'goal.required'     => 'Укажите цель.',
            'goal.string'       => 'Цель должна быть строкой.',
        ];
    }
}
