<?php

use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Finance\Controllers\FinanceController;
use App\Modules\Finance\Controllers\KaspiBankController;
use App\Modules\Health\Controllers\DietController;
use App\Modules\Health\Controllers\SleepController;
use App\Modules\Health\Controllers\SportController;
use App\Modules\Health\Controllers\WaterController;
use App\Modules\Task\Controllers\TaskController;
use Illuminate\Support\Facades\Route;

// AUTH
Route::post('/register',                             [AuthController::class, 'register']);
Route::post('/login',                                [AuthController::class, 'login']);
Route::middleware(['auth:sanctum'])->post('/logout', [AuthController::class, 'logout']);
Route::middleware(['auth:sanctum'])->get('/user',    [AuthController::class, 'getUser']);

// SPORT
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/sport/types',                    [SportController::class, 'getSportTypes']);
    Route::post('/sport/select',                  [SportController::class, 'selectSport']);
    Route::post('/sport/analyze',                 [SportController::class, 'analyzeSport']);
    Route::post('/sport/user-training-program',   [SportController::class, 'addUserTrainingProgram']);
    Route::post('/sport/complete-training',       [SportController::class, 'completeTraining']);
});

// WATER
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/water/set-daily-goal',     [WaterController::class, 'setDailyGoal']);
    Route::post('/water/add-glass',          [WaterController::class, 'addGlass']);
    Route::get('/water/daily-stats',         [WaterController::class, 'getDailyStats']);
    Route::get('/water/overall-stats',       [WaterController::class, 'getOverallStats']);
    Route::get('/water/daily-consumption',   [WaterController::class, 'getDailyConsumption']);
    Route::get('/water/weekly-consumption',  [WaterController::class, 'getWeeklyConsumption']);
    Route::get('/water/monthly-consumption', [WaterController::class, 'getMonthlyConsumption']);
});

// SLEEP
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/sleep/record',         [SleepController::class, 'recordSleep']);
    Route::get('/sleep/recommendations', [SleepController::class, 'getRecommendations']);
});

// FINANCE
Route::post('/import-pdf', [KaspiBankController::class, 'importPdf']);
Route::post('/analyze',    [KaspiBankController::class, 'analyze']);

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/finance/calculate',  [FinanceController::class, 'calculateFinance']);
    Route::post('/finance/record',     [FinanceController::class, 'storeFinanceRecord']);
    Route::get('/finance/records',     [FinanceController::class, 'getFinanceRecords']);
    Route::put('/finance/record/{id}', [FinanceController::class, 'updateFinanceRecord']);
});

// TASK
Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/{task}/complete',   [TaskController::class, 'markAsCompleted']);
});

// DIET
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/diet/food',        [DietController::class, 'addFood']);
    Route::get('/diet/daily/{date}', [DietController::class, 'getDailyDiet']);
    Route::get('/diet/weekly',       [DietController::class, 'getWeeklyDiet']);
});
