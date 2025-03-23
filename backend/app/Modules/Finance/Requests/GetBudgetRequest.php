<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetBudgetRequest extends FormRequest
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
            'period'      => 'nullable|string|in:week,month,year',
            'category_id' => 'nullable|integer|exists:finance_categories,id',
        ];
    }
}
