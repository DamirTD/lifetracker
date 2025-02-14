<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="SelectSportRequest",
 *     required={"sport_id"},
 *     @OA\Property(
 *         property="sport_id",
 *         type="integer",
 *         description="ID выбранного вида спорта",
 *         example=1
 *     )
 * )
 */
class SelectSportRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'sport_id' => ['required', 'integer', 'exists:sports,id']
        ];
    }

    public function messages(): array
    {
        return [
            'sport_id.required' => 'Выберите вид спорта.',
            'sport_id.integer'  => 'ID спорта должен быть числом.',
            'sport_id.exists'   => 'Выбранный вид спорта недействителен.'
        ];
    }
}
