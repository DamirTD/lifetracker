<?php

use App\Modules\Health\Controllers\DietController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    // Получение доступных продуктов
    Route::get('/diet/foods', [DietController::class, 'getFoods']);

    // Управление записями в рационе
    Route::post('/diet/food', [DietController::class, 'addFood']);
    Route::put('/diet/food/{id}', [DietController::class, 'updateFood']);
    Route::delete('/diet/food/{id}', [DietController::class, 'deleteFood']);

    // Получение данных о рационе
    Route::get('/diet/daily/{date}', [DietController::class, 'getDailyDiet']);
    Route::get('/diet/weekly', [DietController::class, 'getWeeklyDiet']);
    Route::get('/diet/monthly', [DietController::class, 'getMonthlyDiet']);

    // Статистика
    Route::get('/diet/statistics', [DietController::class, 'getStatistics']);

    // Управление целями питания
    Route::get('/diet/goals', [DietController::class, 'getDietGoals']);
    Route::put('/diet/goals', [DietController::class, 'updateDietGoals']);
});
