<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

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
            'period'     => 'nullable|string|in:day,week,month,year,custom',
            'start_date' => 'nullable|date',
            'end_date'   => 'nullable|date|after_or_equal:start_date',
        ];
    }
}
