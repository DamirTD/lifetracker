<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="StoreFinanceRecordRequest",
 *     required={"amount", "type", "category_id", "date"},
 *     @OA\Property(
 *         property="amount",
 *         type="number",
 *         format="float",
 *         description="Сумма записи."
 *     ),
 *     @OA\Property(
 *         property="type",
 *         type="string",
 *         enum={"expense", "income", "saving", "investment"},
 *         description="Тип записи."
 *     ),
 *     @OA\Property(
 *         property="category_id",
 *         type="integer",
 *         description="ID категории."
 *     ),
 *     @OA\Property(
 *         property="date",
 *         type="string",
 *         format="date",
 *         description="Дата записи."
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
            'type'        => 'required|in:expense,income,saving,investment',
            'category_id' => 'required|integer|exists:finance_categories,id',
            'date'        => 'required|date',
            'description' => 'nullable|string|max:255',
        ];
    }
}
