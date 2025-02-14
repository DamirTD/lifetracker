<?php

use App\Modules\Health\Controllers\SportController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/sport/list', [SportController::class, 'getSportList']);
    Route::get('/sport/user-sport-list', [SportController::class, 'getUserSportList']);
    Route::post('/sport/select-user-sport', [SportController::class, 'selectUserSport']);
    Route::post('/sport/basic-training-program', [SportController::class, 'basicTrainingProgram']);
    Route::post('/sport/create-personal-training-program', [SportController::class, 'addUserTrainingProgram']);
    Route::post('/sport/complete-training', [SportController::class, 'completeTraining']);
    Route::put('/sport/edit/{id}', [SportController::class, 'editSport']);
    Route::delete('/sport/user-sport/{id}', [SportController::class, 'deleteSport']);
});
