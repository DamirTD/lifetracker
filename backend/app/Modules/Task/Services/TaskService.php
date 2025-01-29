<?php

namespace App\Modules\Task\Services;

use App\Models\Task;
use App\Modules\Task\QueryInterfaces\TaskQueryInterface;
use App\Modules\Task\Repository\TaskRepository;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;
use App\Modules\Task\ServiceInterfaces\TaskServiceInterface;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Auth;

class TaskService implements TaskServiceInterface
{
    public function __construct(
        protected TaskRepositoryInterface $taskRepository,
        protected TaskQueryInterface $taskQuery
    ){
    }

    public function markAsCompleted(Task $task): Task
    {
        return $this->taskRepository->markAsCompleted($task);
    }

    public function getTasks(): LengthAwarePaginator
    {
        return $this->taskQuery->getAllTasks(Auth::id());
    }

    public function createTask(array $data): Task
    {
        $data['user_id'] = Auth::id();
        return $this->taskRepository->create($data);
    }

    public function updateTask(Task $task, array $data): Task
    {
        return $this->taskRepository->update($task, $data);
    }

    public function deleteTask(Task $task): void
    {
        $this->taskRepository->delete($task);
    }
}
