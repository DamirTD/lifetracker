<?php

namespace App\Modules\Task\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TaskCategoryRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255|unique:task_categories,name,NULL,id,user_id,' . auth()->id(),
        ];
    }
}
