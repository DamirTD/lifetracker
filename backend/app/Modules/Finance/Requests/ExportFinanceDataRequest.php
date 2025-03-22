<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ExportFinanceDataRequest extends FormRequest
{
    /**
     * @return bool
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'format'     => 'required|string|in:csv,pdf,excel',
            'period'     => 'required|string|in:week,month,year,custom',
            'start_date' => 'nullable|date|required_if:period,custom',
            'end_date'   => 'nullable|date|required_if:period,custom|after_or_equal:start_date',
            'type'       => 'nullable|string|in:expense,income,saving,investment,all',
        ];
    }
}
