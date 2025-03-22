<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetFinancialGoalsRequest extends FormRequest
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
            'status'   => 'nullable|string|in:active,completed,all',
            'priority' => 'nullable|string|in:low,medium,high',
        ];
    }

    /**
     * @return void
     */
    protected function prepareForValidation(): void
    {
        if (!$this->has('status')) {
            $this->merge(['status' => 'active']);
        }
    }
}
