<?php

use App\Modules\Health\Controllers\SleepController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/sleep/record',         [SleepController::class, 'recordSleep']);
    Route::get('/sleep/recommendations', [SleepController::class, 'getRecommendations']);
});
