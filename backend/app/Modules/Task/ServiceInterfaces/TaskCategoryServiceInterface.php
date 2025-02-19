<?php

namespace App\Modules\Task\ServiceInterfaces;

use App\Models\TaskCategory;
use Illuminate\Database\Eloquent\Collection;

interface TaskCategoryServiceInterface{
    public function getUserCategories(): Collection;
    public function createCategory(array $data): TaskCategory;
}
