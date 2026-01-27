<?php

namespace App\Modules\Task\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;
use App\Modules\Task\Requests\TaskRequest;
use App\Modules\Task\Resources\TaskCategoryResource;
use App\Modules\Task\Resources\TaskResource;
use App\Modules\Task\ServiceInterfaces\TaskServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response as ResponseAlias;

class TaskController extends Controller {
    public function __construct(
        protected TaskServiceInterface $taskService,
        protected TaskRepositoryInterface $taskRepository,
    ) {
    }

    /**
     * @OA\Get(
     *     path="/api/tasks",
     *     summary="Получение списка задач",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\Response(
     *         response=200,
     *         description="Список задач",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(
     *                 @OA\Property(property="date", type="string", example="18.02.2025"),
     *                 @OA\Property(property="category", ref="#/components/schemas/TaskCategoryResource"),
     *                 @OA\Property(property="tasks", type="array",
     *                     @OA\Items(ref="#/components/schemas/TaskResource")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function index(): JsonResource
    {
        $groupedTasks = $this->taskService->getTasks(Auth::id());

        $result = $groupedTasks->map(function ($tasks, $key) {
            $keyParts = explode('|', $key);
            $date = array_shift($keyParts);

            return [
                'date'     => $date,
                'category' => new TaskCategoryResource($tasks->first()->category),
                'tasks'    => TaskResource::collection($tasks),
            ];
        })->values();

        return JsonResource::collection($result);
    }

    /**
     * @OA\Post
     *     path="/api/tasks",
     *     summary="Создание новой задачи",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TaskRequest")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Задача успешно создана",
     *         @OA\JsonContent(ref="#/components/schemas/TaskResource")
     *     )
     * )
     */
    public function store(TaskRequest $request): TaskResource
    {
        return new TaskResource($this->taskService->createTask($request->validated()));
    }

    /**
     * @OA\Put(
     *     path="/api/tasks/{task}",
     *     summary="Обновление задачи",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="task",
     *         in="path",
     *         required=true,
     *         description="ID задачи",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TaskRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Задача успешно обновлена",
     *         @OA\JsonContent(ref="#/components/schemas/TaskResource")
     *     )
     * )
     */
    public function update(TaskRequest $request, Task $task): TaskResource
    {
        return new TaskResource($this->taskService->updateTask($task, $request->validated()));
    }

    /**
     * @OA\Delete(
     *     path="/api/tasks/{task}",
     *     summary="Удаление задачи",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="task",
     *         in="path",
     *         required=true,
     *         description="ID задачи",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=204,
     *         description="Задача успешно удалена"
     *     )
     * )
     */
    public function destroy(Task $task): JsonResponse
    {
        $this->taskService->deleteTask($task);
        return response()->json(['message' => 'Task deleted'], ResponseAlias::HTTP_NO_CONTENT);
    }

    /**
     * @OA\Patch(
     *     path="/api/tasks/{task}/complete",
     *     summary="Отметить задачу как выполненную",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="task",
     *         in="path",
     *         required=true,
     *         description="ID задачи",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Задача отмечена как выполненная",
     *         @OA\JsonContent(ref="#/components/schemas/TaskResource")
     *     )
     * )
     */
    public function markAsCompleted(Task $task): TaskResource
    {
        return new TaskResource($this->taskService->markAsCompleted($task));
    }

    /**
     * @OA\Patch(
     *     path="/api/tasks/{task}/incomplete",
     *     summary="Отменить выполнение задачи",
     *     tags={"Tasks"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="task",
     *         in="path",
     *         required=true,
     *         description="ID задачи",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Выполнение задачи отменено",
     *         @OA\JsonContent(ref="#/components/schemas/TaskResource")
     *     )
     * )
     */
    public function markAsIncomplete(Task $task): TaskResource
    {
        return new TaskResource($this->taskService->markAsIncomplete($task));
    }
}
