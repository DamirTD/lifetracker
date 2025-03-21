<?php

namespace App\Modules\Task\Repositories;

use App\Models\TaskCategory;
use App\Modules\Task\RepositoryInterfaces\TaskCategoryRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class TaskCategoryRepository implements TaskCategoryRepositoryInterface
{
    public function getCategoriesByUserId(int $userId): Collection
    {
        return TaskCategory::where('user_id', $userId)->get();
    }

    public function create(array $data): TaskCategory
    {
        return TaskCategory::create($data);
    }

    public function findById(int $id): ?TaskCategory
    {
        return TaskCategory::find($id);
    }

    public function delete(int $id): bool
    {
        return TaskCategory::destroy($id) > 0;
    }

    public function update(int $id, array $data): ?TaskCategory
    {
        $category = $this->findById($id);

        if (!$category) {
            return null;
        }

        $category->update($data);
        return $category->fresh();
    }
}
