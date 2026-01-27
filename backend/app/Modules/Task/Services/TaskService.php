<?php

namespace App\Modules\Task\Services;

use App\Models\Task;
use App\Models\TaskCategory;
use App\Modules\Task\QueryInterfaces\TaskQueryInterface;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;
use App\Modules\Task\ServiceInterfaces\TaskServiceInterface;
use Illuminate\Support\Collection;
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

    public function markAsIncomplete(Task $task): Task
    {
        return $this->taskRepository->markAsIncomplete($task);
    }

    public function createTask(array $data): Task {
        $userId = Auth::id();

        if (isset($data['category'])) {
            TaskCategory::firstOrCreate([
                'name'    => $data['category'],
                'user_id' => $userId,
            ]);
        }

        return $this->taskRepository->create([
            'user_id'      => $userId,
            'title'        => $data['title'],
            'description'  => $data['description'] ?? null,
            'priority'     => $data['priority'],
            'category_id'  => $data['category_id'],
            'due_date'     => $data['due_date'] ?? null,
            'is_completed' => $data['is_completed'] ?? false,
        ]);
    }

    public function updateTask(Task $task, array $data): Task
    {
        return $this->taskRepository->update($task, $data);
    }

    public function deleteTask(Task $task): void
    {
        $this->taskRepository->delete($task);
    }

    public function getTasks($userId): Collection
    {
        return Task::where('user_id', $userId)
            ->with('category')
            ->latest()
            ->get()
            ->groupBy(function($task) {
                $formattedDate = $task->due_date ? $task->due_date->format('d.m.Y') : 'No Date';

                return "{$formattedDate}|{$task->category->id}";
            });
    }
}
