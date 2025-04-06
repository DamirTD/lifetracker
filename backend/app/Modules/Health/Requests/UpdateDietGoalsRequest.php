<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateDietGoalsRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'calories'      => 'required|integer|min:500|max:10000',
            'protein'       => 'required|numeric|min:0|max:1000',
            'fat'           => 'required|numeric|min:0|max:1000',
            'carbohydrates' => 'required|numeric|min:0|max:1000',
        ];
    }
}
