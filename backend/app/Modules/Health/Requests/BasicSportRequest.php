<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="BasicSportRequest",
 *     required={"sport_id", "goal"},
 *     @OA\Property(
 * *         property="sport_id",
 * *         type="integer",
 * *         description="ID выбранного вида спорта",
 * *         example=1
 * *     ),
 *     @OA\Property(
 *         property="goal",
 *         type="string",
 *         description="Цель занятий спортом"
 *     )
 * )
 */
class BasicSportRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'sport_id' => ['required', 'integer', 'exists:sports,id'],
            'goal'     => 'required|string',
        ];
    }

    public function messages(): array
    {
        return [
            'sport_id.required' => 'Выберите вид спорта.',
            'sport_id.exists'   => 'Выбранный вид спорта недействителен.',
            'goal.required'     => 'Укажите цель.',
        ];
    }
}
