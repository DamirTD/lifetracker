<?php

use App\Modules\Health\Controllers\SportController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->prefix('sport')->group(function () {
    Route::get('/list',                    [SportController::class, 'getSportList']);
    Route::get('/user-sport-list',         [SportController::class, 'getUserSportList']);
    Route::post('/select-user-sport',      [SportController::class, 'selectUserSport']);
    Route::post('/basic-training-program', [SportController::class, 'basicTrainingProgram']);
    Route::put('/edit/{id}',               [SportController::class, 'editSport']);
    Route::delete('/user-sport/{id}',      [SportController::class, 'deleteSport']);

    Route::post('/create-personal-training-program', [SportController::class, 'addUserTrainingProgram']);
    Route::post('/complete-training',                [SportController::class, 'completeTraining']);
    Route::get('/training-program/{id}',             [SportController::class, 'getTrainingProgram']);
    Route::get('/training-history',                  [SportController::class, 'getTrainingHistory']);
});
