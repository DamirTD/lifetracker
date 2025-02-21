<?php

use App\Modules\Health\Controllers\DietController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/diet/food',        [DietController::class, 'addFood']);
    Route::get('/diet/daily/{date}', [DietController::class, 'getDailyDiet']);
    Route::get('/diet/weekly',       [DietController::class, 'getWeeklyDiet']);
});
