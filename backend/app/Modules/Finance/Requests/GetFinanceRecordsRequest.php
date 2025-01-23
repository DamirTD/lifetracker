<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="GetFinanceRecordsRequest",
 *     required={"period"},
 *     @OA\Property(
 *         property="period",
 *         type="string",
 *         enum={"week", "month", "year"},
 *         description="Период записей."
 *     )
 * )
 */
class GetFinanceRecordsRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'period' => 'required|in:week,month,year',
        ];
    }
}
