<?php

namespace App\Modules\Task\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="TaskResource",
 *     title="TaskResource",
 *     description="Ресурс задачи",
 *     @OA\Property(property="id", type="integer", example=1),
 *     @OA\Property(property="title", type="string", example="Сделать тест"),
 *     @OA\Property(property="description", type="string", example="Подготовить отчет"),
 *     @OA\Property(property="priority", type="string", example="high"),
 *     @OA\Property(property="category", type="string", example="study"),
 *     @OA\Property(property="due_date", type="string", example="18.02.2025"),
 *     @OA\Property(property="is_completed", type="boolean", example=false),
 * )
 */
class TaskResource extends JsonResource {
    public function toArray(Request $request): array {
        return [
            'id'           => $this->id,
            'title'        => $this->title,
            'description'  => $this->description,
            'priority'     => $this->priority,
            'category'     => new TaskCategoryResource($this->category),
            'due_date'     => $this->due_date?->format('d.m.Y'),
            'is_completed' => (bool) $this->is_completed,
        ];
    }
}
