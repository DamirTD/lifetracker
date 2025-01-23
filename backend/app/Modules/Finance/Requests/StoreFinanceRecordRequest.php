<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="StoreFinanceRecordRequest",
 *     required={"amount", "type", "period"},
 *     @OA\Property(
 *         property="amount",
 *         type="number",
 *         format="float",
 *         description="Сумма записи."
 *     ),
 *     @OA\Property(
 *         property="type",
 *         type="string",
 *         enum={"expense", "saving"},
 *         description="Тип записи (расход или сбережение)."
 *     ),
 *     @OA\Property(
 *         property="period",
 *         type="string",
 *         enum={"week", "month", "year"},
 *         description="Период записи."
 *     ),
 *     @OA\Property(
 *         property="description",
 *         type="string",
 *         description="Описание записи (опционально)."
 *     )
 * )
 */
class StoreFinanceRecordRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'amount'      => 'required|numeric|min:0',
            'type'        => 'required|in:expense,saving',
            'period'      => 'required|in:week,month,year',
            'description' => 'nullable|string|max:255',
        ];
    }
}
