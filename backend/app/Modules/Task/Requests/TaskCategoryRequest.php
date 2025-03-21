<?php

namespace App\Modules\Task\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TaskCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
        ];
    }

    /**
     * @OA\Schema(
     *     schema="TaskCategoryRequest",
     *     required={"name"},
     *     @OA\Property(property="name", type="string", example="Работа"),
     * )
     */
    public function validated($key = null, $default = null)
    {
        return parent::validated($key, $default);
    }
}
