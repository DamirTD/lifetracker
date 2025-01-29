<?php

namespace App\Modules\Task\Query;

use App\Models\Task;
use App\Modules\Task\QueryInterfaces\TaskQueryInterface;
use Illuminate\Pagination\LengthAwarePaginator;

class TaskQuery implements TaskQueryInterface
{
    public function getAllTasks($userId): LengthAwarePaginator
    {
        return Task::where('user_id', $userId)->latest()->paginate(10);
    }
}
