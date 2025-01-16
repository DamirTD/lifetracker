<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetDailyGoalRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'weight'          => 'required|numeric|min:30|max:300',
            'height'          => 'required|numeric|min:100|max:250',
            'goal'            => 'required|string|in:maintain,lose_weight',
            'glass_volume_ml' => 'required|integer|min:50|max:1000',
        ];
    }

    //TODO: MESSAGES
}
