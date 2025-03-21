<?php

namespace App\Modules\Task\Services;

use App\Models\TaskCategory;
use App\Modules\Task\RepositoryInterfaces\TaskCategoryRepositoryInterface;
use App\Modules\Task\ServiceInterfaces\TaskCategoryServiceInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Auth;

class TaskCategoryService implements TaskCategoryServiceInterface
{
    public function __construct(
        protected TaskCategoryRepositoryInterface $taskCategoryRepository
    ) {
    }

    public function getUserCategories(): Collection
    {
        $userId = Auth::id();
        $categories = $this->taskCategoryRepository->getCategoriesByUserId($userId);

        if ($categories->isEmpty()) {
            $this->createDefaultCategoriesIfNeeded($userId);
            $categories = $this->taskCategoryRepository->getCategoriesByUserId($userId);
        }

        return $categories;
    }

    public function createCategory(array $data): TaskCategory
    {
        $data['user_id'] = Auth::id();
        return $this->taskCategoryRepository->create($data);
    }

    public function createDefaultCategoriesIfNeeded(int $userId): void
    {
        $defaultCategories = [
            ['name' => 'Работа', 'user_id' => $userId],
            ['name' => 'Личное', 'user_id' => $userId],
            ['name' => 'Учеба',  'user_id' => $userId],
        ];

        foreach ($defaultCategories as $category) {
            $this->taskCategoryRepository->create($category);
        }
    }

    public function deleteCategory(int $categoryId): bool
    {
        $userId = Auth::id();
        $category = $this->taskCategoryRepository->findById($categoryId);

        if (!$category || $category->user_id !== $userId) {
            return false;
        }

        return $this->taskCategoryRepository->delete($categoryId);
    }

    public function updateCategory(int $categoryId, array $data): ?TaskCategory
    {
        $userId = Auth::id();
        $category = $this->taskCategoryRepository->findById($categoryId);

        if (!$category || $category->user_id !== $userId) {
            return null;
        }

        return $this->taskCategoryRepository->update($categoryId, $data);
    }
}
