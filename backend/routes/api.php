<?php

use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Health\Controllers\WaterController;
use Illuminate\Support\Facades\Route;

// AUTH
Route::post('/register',                             [AuthController::class, 'register']);
Route::post('/login',                                [AuthController::class, 'login']);
Route::middleware(['auth:sanctum'])->post('/logout', [AuthController::class, 'logout']);

// WATER
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/water/set-daily-goal', [WaterController::class, 'setDailyGoal']);
    Route::post('/water/add-glass',      [WaterController::class, 'addGlass']);
    Route::get('/water/daily-stats',     [WaterController::class, 'getDailyStats']);
    Route::get('/water/overall-stats',   [WaterController::class, 'getOverallStats']);
});
