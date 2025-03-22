<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetFinanceStatisticsRequest extends FormRequest
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
            'period'     => 'nullable|string|in:day,week,month,year,custom',
            'type'       => 'nullable|string|in:expense,income,saving,investment',
            'start_date' => 'nullable|date|required_if:period,custom',
            'end_date'   => 'nullable|date|required_if:period,custom|after_or_equal:start_date',
            'group_by'   => 'nullable|string|in:day,week,month,year,category',
        ];
    }

    /**
     * @return void
     */
    protected function prepareForValidation(): void
    {
        if (!$this->has('period')) {
            $this->merge(['period' => 'month']);
        }

        if (!$this->has('group_by')) {
            $this->merge(['group_by' => 'day']);
        }
    }
}
