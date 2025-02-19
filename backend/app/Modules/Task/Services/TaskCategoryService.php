<?php

namespace App\Modules\Task\Services;

use App\Models\TaskCategory;
use App\Modules\Task\ServiceInterfaces\TaskCategoryServiceInterface;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\Collection;

class TaskCategoryService implements TaskCategoryServiceInterface
{
    public function getUserCategories(): Collection
    {
        return TaskCategory::where('user_id', Auth::id())->get();
    }

    public function createCategory(array $data): TaskCategory
    {
        return TaskCategory::create([
            'user_id' => Auth::id(),
            'name'    => $data['name'],
        ]);
    }
}
