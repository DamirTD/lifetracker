<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetMonthlyRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'year'  => 'nullable|integer|min:2000|max:' . (date('Y') + 1),
            'month' => 'nullable|integer|min:1|max:12',
        ];
    }
}
