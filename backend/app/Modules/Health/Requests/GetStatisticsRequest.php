<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetStatisticsRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'period' => 'required|string|in:week,month,quarter,year',
        ];
    }
}
