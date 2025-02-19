<?php

namespace App\Modules\Task\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="TaskRequest",
 *     title="TaskRequest",
 *     description="Запрос на создание или обновление задачи",
 *     required={"title", "priority", "category"},
 *     @OA\Property(property="title", type="string", example="Сделать тест"),
 *     @OA\Property(property="description", type="string", nullable=true, example="Подготовить отчет"),
 *     @OA\Property(property="priority", type="string", enum={"low", "medium", "high"}, example="high"),
 *     @OA\Property(property="category", type="string", example="study"),
 *     @OA\Property(property="due_date", type="string", format="date-time", nullable=true, example="2024-01-30 12:00:00"),
 *     @OA\Property(property="is_completed", type="boolean", example=false),
 * )
 */
class TaskRequest extends FormRequest {
    public function rules(): array {
        return [
            'title'       => 'required|string|max:255',
            'description' => 'nullable|string',
            'priority'    => 'required|string|in:low,medium,high',
            'category'    => 'required|string|max:255',
            'due_date'    => 'sometimes|nullable|date_format:Y-m-d H:i:s',
            'is_completed' => 'sometimes|boolean',
        ];
    }
}
