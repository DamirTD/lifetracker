<?php

namespace App\Modules\Task\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Task\Requests\TaskCategoryRequest;
use App\Modules\Task\Resources\TaskCategoryResource;
use App\Modules\Task\ServiceInterfaces\TaskCategoryServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;

class TaskCategoryController extends Controller
{
    public function __construct(
        protected TaskCategoryServiceInterface $taskCategoryService
    ) {}

    /**
     * @OA\Get(
     *     path="/api/categories",
     *     summary="Получение списка категорий задач",
     *     tags={"Task Categories"},
     *     security={{ "sanctum": {} }},
     *     @OA\Response(
     *         response=200,
     *         description="Список категорий задач",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(ref="#/components/schemas/TaskCategoryResource")
     *         )
     *     )
     * )
     */
    public function index(): JsonResource
    {
        $categories = $this->taskCategoryService->getUserCategories();
        return TaskCategoryResource::collection($categories);
    }

    /**
     * @OA\Post(
     *     path="/api/categories",
     *     summary="Создание новой категории задач",
     *     tags={"Task Categories"},
     *     security={{ "sanctum": {} }},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TaskCategoryRequest")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Категория успешно создана",
     *         @OA\JsonContent(ref="#/components/schemas/TaskCategoryResource")
     *     )
     * )
     */
    public function store(TaskCategoryRequest $request): JsonResponse
    {
        $category = $this->taskCategoryService->createCategory($request->validated());
        return response()->json([
            'data' => new TaskCategoryResource($category),
        ], HttpStatusCodes::CREATED);
    }

    /**
     * @OA\Delete(
     *     path="/api/categories/{category}",
     *     summary="Удаление категории задач",
     *     tags={"Task Categories"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="category",
     *         in="path",
     *         required=true,
     *         description="ID категории",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=204,
     *         description="Категория успешно удалена"
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Доступ запрещен"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Категория не найдена"
     *     )
     * )
     */
    public function destroy(int $category): JsonResponse
    {
        $result = $this->taskCategoryService->deleteCategory($category);

        if (!$result) {
            return response()->json(
                ['message' => 'Category not found or you do not have permission to delete it'],
                HttpStatusCodes::NOT_FOUND
            );
        }

        return response()->json(null, HttpStatusCodes::NO_CONTENT);
    }

    /**
     * @OA\Put(
     *     path="/api/categories/{category}",
     *     summary="Обновление категории задач",
     *     tags={"Task Categories"},
     *     security={{ "sanctum": {} }},
     *     @OA\Parameter(
     *         name="category",
     *         in="path",
     *         required=true,
     *         description="ID категории",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/TaskCategoryRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Категория успешно обновлена",
     *         @OA\JsonContent(ref="#/components/schemas/TaskCategoryResource")
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Доступ запрещен"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Категория не найдена"
     *     )
     * )
     */
    public function update(TaskCategoryRequest $request, int $category): JsonResponse
    {
        $updated = $this->taskCategoryService->updateCategory($category, $request->validated());

        if (!$updated) {
            return response()->json(
                ['message' => 'Category not found or you do not have permission to update it'],
                HttpStatusCodes::NOT_FOUND
            );
        }

        return response()->json(new TaskCategoryResource($updated));
    }
}
