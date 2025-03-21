<?php

namespace App\Modules\Task\ServiceInterfaces;

use App\Models\TaskCategory;
use Illuminate\Database\Eloquent\Collection;

interface TaskCategoryServiceInterface
{
    /**
     * @return Collection
     */
    public function getUserCategories(): Collection;

    /**
     * @param array $data
     * @return TaskCategory
     */
    public function createCategory(array $data): TaskCategory;

    /**
     * @param int $userId
     * @return void
     */
    public function createDefaultCategoriesIfNeeded(int $userId): void;

    /**
     * @param int $categoryId
     * @return bool
     */
    public function deleteCategory(int $categoryId): bool;

    /**
     * @param int $categoryId
     * @param array $data
     * @return TaskCategory|null
     */
    public function updateCategory(int $categoryId, array $data): ?TaskCategory;
}
