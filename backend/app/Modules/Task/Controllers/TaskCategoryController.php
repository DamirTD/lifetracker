<?php

namespace App\Modules\Task\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Task\Requests\TaskCategoryRequest;
use App\Modules\Task\ServiceInterfaces\TaskCategoryServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;

class TaskCategoryController extends Controller
{
    public function __construct(
        protected TaskCategoryServiceInterface $taskCategoryService
    ) {
    }

    public function index(): JsonResponse
    {
        return response()->json($this->taskCategoryService->getUserCategories());
    }

    public function store(TaskCategoryRequest $request): JsonResponse
    {
        $category = $this->taskCategoryService->createCategory($request->validated());

        return response()->json($category, HttpStatusCodes::CREATED);
    }
}
