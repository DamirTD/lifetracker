<?php

namespace App\Modules\Task\ServiceInterfaces;

use App\Models\Task;

interface TaskServiceInterface
{
    public function markAsCompleted(Task $task): Task;
    public function getTasks();
    public function createTask(array $data);
    public function updateTask(Task $task, array $data);
    public function deleteTask(Task $task);
}
