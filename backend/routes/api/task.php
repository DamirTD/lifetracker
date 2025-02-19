<?php

use App\Modules\Task\Controllers\TaskCategoryController;
use App\Modules\Task\Controllers\TaskController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/{task}/complete', [TaskController::class, 'markAsCompleted']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/categories', [TaskCategoryController::class, 'store']);
    Route::get('/categories', [TaskCategoryController::class, 'index']);
});
