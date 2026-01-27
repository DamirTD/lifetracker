<?php

namespace App\Modules\Task\Repositories;

use App\Models\Task;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;

class TaskRepository implements TaskRepositoryInterface
{
    public function create(array $data): Task {
        return Task::create($data);
    }

    public function update(Task $task, array $data): Task {
        $task->update($data);
        return $task;
    }

    public function delete(Task $task): void {
        $task->delete();
    }

    public function markAsCompleted(Task $task): Task
    {
        $task->update(['is_completed' => true]);
        return $task;
    }

    public function markAsIncomplete(Task $task): Task
    {
        $task->update(['is_completed' => false]);
        return $task;
    }
}
