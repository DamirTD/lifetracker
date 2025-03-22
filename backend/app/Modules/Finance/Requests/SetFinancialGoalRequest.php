<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetFinancialGoalRequest extends FormRequest
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
            'name'           => 'required|string|max:255',
            'target_amount'  => 'required|numeric|min:0.01',
            'target_date'    => 'required|date|after:today',
            'current_amount' => 'nullable|numeric|min:0',
            'description'    => 'nullable|string|max:500',
            'priority'       => 'nullable|string|in:low,medium,high',
        ];
    }
}
