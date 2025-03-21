<?php

namespace App\Modules\Task\RepositoryInterfaces;

use App\Models\TaskCategory;
use Illuminate\Database\Eloquent\Collection;

interface TaskCategoryRepositoryInterface
{
    /**
     * @param int $userId
     * @return Collection
     */
    public function getCategoriesByUserId(int $userId): Collection;

    /**
     * @param array $data
     * @return TaskCategory
     */
    public function create(array $data): TaskCategory;

    /**
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool;

    /**
     * @param int $id
     * @param array $data
     * @return TaskCategory|null
     */
    public function update(int $id, array $data): ?TaskCategory;

    /**
     * @param int $id
     * @return TaskCategory|null
     */
    public function findById(int $id): ?TaskCategory;
}
