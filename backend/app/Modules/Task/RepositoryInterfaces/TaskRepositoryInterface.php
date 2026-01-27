<?php

namespace App\Modules\Task\RepositoryInterfaces;

use App\Models\Task;

interface TaskRepositoryInterface
{
    public function create(array $data): Task;
    public function update(Task $task, array $data): Task;
    public function delete(Task $task): void;
    public function markAsCompleted(Task $task): Task;
    public function markAsIncomplete(Task $task): Task;
}
