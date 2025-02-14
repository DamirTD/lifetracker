<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Health\Controllers\WaterController;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/water/set-daily-goal',     [WaterController::class, 'setDailyGoal']);
    Route::post('/water/add-glass',          [WaterController::class, 'addGlass']);
    Route::get('/water/daily-stats',         [WaterController::class, 'getDailyStats']);
    Route::get('/water/overall-stats',       [WaterController::class, 'getOverallStats']);
    Route::get('/water/daily-consumption',   [WaterController::class, 'getDailyConsumption']);
    Route::get('/water/weekly-consumption',  [WaterController::class, 'getWeeklyConsumption']);
    Route::get('/water/monthly-consumption', [WaterController::class, 'getMonthlyConsumption']);
});
