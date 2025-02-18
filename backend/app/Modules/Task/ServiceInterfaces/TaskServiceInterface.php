<?php

namespace App\Modules\Task\ServiceInterfaces;

use App\Models\Task;
use Illuminate\Support\Collection;

interface TaskServiceInterface
{
    public function markAsCompleted(Task $task): Task;
    public function createTask(array $data);
    public function updateTask(Task $task, array $data);
    public function deleteTask(Task $task);
    public function getTaskGroupedByDate($userId): Collection;
}
