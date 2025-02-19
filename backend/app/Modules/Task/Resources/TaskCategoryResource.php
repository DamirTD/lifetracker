<?php

namespace App\Modules\Task\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @OA\Schema(
 *     schema="TaskCategoryResource",
 *     title="TaskCategoryResource",
 *     description="Ресурс категории задачи",
 *     @OA\Property(property="id", type="integer", example=2),
 *     @OA\Property(property="name", type="string", example="work"),
 * )
 */
class TaskCategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'   => $this->id,
            'name' => $this->name,
        ];
    }
}
