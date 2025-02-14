<?php

use App\Modules\Task\Controllers\TaskController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/{task}/complete', [TaskController::class, 'markAsCompleted']);
});
