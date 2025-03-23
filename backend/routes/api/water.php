<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Health\Controllers\WaterController;


Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/water/set-daily-goal',     [WaterController::class, 'setDailyGoal']);
    Route::post('/water/add-glass',          [WaterController::class, 'addGlass']);
    Route::post('/water/remove-glass',       [WaterController::class, 'removeGlass']);
    Route::get('/water/daily-stats',         [WaterController::class, 'getDailyStats']);
    Route::get('/water/overall-stats',       [WaterController::class, 'getOverallStats']);

    Route::get('/water/daily-consumption',   [WaterController::class, 'getDailyConsumption']);
    Route::get('/water/weekly-consumption',  [WaterController::class, 'getWeeklyConsumption']);
    Route::get('/water/monthly-consumption', [WaterController::class, 'getMonthlyConsumption']);
    Route::get('/water/history',             [WaterController::class, 'getHistory']);

    Route::post('/water/save-container',     [WaterController::class, 'saveContainer']);
    Route::get('/water/containers',          [WaterController::class, 'getContainers']);
    Route::delete('/water/containers/{id}',  [WaterController::class, 'deleteContainer']);

    Route::post('/water/set-reminder',       [WaterController::class, 'setReminder']);
    Route::get('/water/reminders',           [WaterController::class, 'getReminders']);
    Route::delete('/water/reminders/{id}',   [WaterController::class, 'deleteReminder']);
    Route::put('/water/reminders/{id}/toggle', [WaterController::class, 'toggleReminder']);

    Route::get('/water/insights',            [WaterController::class, 'getInsights']);
    Route::get('/water/comparison',          [WaterController::class, 'getComparison']);
    Route::get('/water/eco-report',          [WaterController::class, 'getEcoReport']);
});
