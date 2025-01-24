<?php

use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Finance\Controllers\FinanceController;
use App\Modules\Finance\Controllers\KaspiBankController;
use App\Modules\Health\Controllers\SportController;
use App\Modules\Health\Controllers\WaterController;
use Illuminate\Support\Facades\Route;

// AUTH
Route::post('/register',                             [AuthController::class, 'register']);
Route::post('/login',                                [AuthController::class, 'login']);
Route::middleware(['auth:sanctum'])->post('/logout', [AuthController::class, 'logout']);

// SPORT
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/sport/types',    [SportController::class, 'getSportTypes']);
    Route::post('/sport/select',  [SportController::class, 'selectSport']);
    Route::post('/sport/analyze', [SportController::class, 'analyzeSport']);
});

// WATER
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/water/set-daily-goal', [WaterController::class, 'setDailyGoal']);
    Route::post('/water/add-glass',      [WaterController::class, 'addGlass']);
    Route::get('/water/daily-stats',     [WaterController::class, 'getDailyStats']);
    Route::get('/water/overall-stats',   [WaterController::class, 'getOverallStats']);
});

// FINANCE
Route::post('/import-pdf', [KaspiBankController::class, 'importPdf']);
Route::post('/analyze',    [KaspiBankController::class, 'analyze']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/finance/calculate', [FinanceController::class, 'calculateFinance']);
    Route::post('/finance/record',    [FinanceController::class, 'storeFinanceRecord']);
    Route::get('/finance/records',    [FinanceController::class, 'getFinanceRecords']);
});
