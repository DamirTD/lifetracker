<?php

use App\Modules\Health\Controllers\SleepController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/sleep/record',         [SleepController::class, 'recordSleep']);
    Route::get('/sleep/recommendations', [SleepController::class, 'getRecommendations']);

    Route::get('/sleep/stats',        [SleepController::class, 'getStatistics']);
    Route::get('/sleep/trends',       [SleepController::class, 'getTrends']);
    Route::get('/sleep/correlations', [SleepController::class, 'getSleepCorrelations']);

    Route::post('/sleep/goals',         [SleepController::class, 'setSleepGoals']);
    Route::get('/sleep/goals/progress', [SleepController::class, 'getGoalsProgress']);

    Route::post('/sleep/import',     [SleepController::class, 'importDeviceData']);
});
