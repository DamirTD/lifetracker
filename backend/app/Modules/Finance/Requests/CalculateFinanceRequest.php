<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="CalculateFinanceRequest",
 *     required={"salary", "rule"},
 *     @OA\Property(
 *         property="salary",
 *         type="number",
 *         format="float",
 *         description="Зарплата пользователя."
 *     ),
 *     @OA\Property(
 *         property="rule",
 *         type="string",
 *         enum={"50-30-20", "70-20-10", "80-10-10"},
 *         description="Правило распределения финансов."
 *     )
 * )
 */
class CalculateFinanceRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'salary' => 'required|numeric|min:0',
            'rule'   => 'required|in:50-30-20,70-20-10,80-10-10',
        ];
    }
}
