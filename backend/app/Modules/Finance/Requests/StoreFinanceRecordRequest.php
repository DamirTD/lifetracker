<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="StoreFinanceRecordRequest",
 *     required={"amount", "type", "period", "category_id", "date"},
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
 *         property="period",
 *         type="string",
 *         enum={"day", "week", "month", "year"},
 *         description="Период записи."
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
 *     ),
 *     @OA\Property(
 *         property="is_recurring",
 *         type="boolean",
 *         description="Является ли запись регулярной (опционально)."
 *     ),
 *     @OA\Property(
 *         property="recurring_frequency",
 *         type="string",
 *         enum={"daily", "weekly", "monthly", "yearly"},
 *         description="Частота повторения (опционально)."
 *     )
 * )
 */
class StoreFinanceRecordRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'amount'              => 'required|numeric|min:0',
            'type'                => 'required|in:expense,income,saving,investment',
            'period'              => 'required|in:day,week,month,year',
            'category_id'         => 'required|integer|exists:finance_categories,id',
            'date'                => 'required|date',
            'description'         => 'nullable|string|max:255',
            'is_recurring'        => 'nullable|boolean',
            'recurring_frequency' => 'nullable|in:daily,weekly,monthly,yearly',
        ];
    }
}
