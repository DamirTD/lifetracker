<?php

use App\Modules\Finance\Controllers\FinanceController;
use App\Modules\Finance\Controllers\KaspiBankController;
use Illuminate\Support\Facades\Route;

Route::post('/import-pdf', [KaspiBankController::class, 'importPdf']);
Route::post('/analyze',    [KaspiBankController::class, 'analyze']);

Route::middleware(['auth:sanctum'])->prefix('finance')->group(function () {
    Route::post('/calculate', [FinanceController::class, 'calculateFinance']);
    Route::get('/advice',     [FinanceController::class, 'getFinancialAdvice']);

    Route::post('/record',        [FinanceController::class, 'storeFinanceRecord']);
    Route::get('/records',        [FinanceController::class, 'getFinanceRecords']);
    Route::put('/record/{id}',    [FinanceController::class, 'updateFinanceRecord']);
    Route::delete('/record/{id}', [FinanceController::class, 'deleteFinanceRecord']);

    Route::get('/statistics', [FinanceController::class, 'getFinanceStatistics']);

    Route::post('/budget', [FinanceController::class, 'createBudget']);
    Route::get('/budgets', [FinanceController::class, 'getBudgets']);

    Route::post('/goal',              [FinanceController::class, 'setFinancialGoal']);
    Route::get('/goals',              [FinanceController::class, 'getFinancialGoals']);
    Route::put('/goal/{id}/progress', [FinanceController::class, 'updateGoalProgress']);

    Route::post('/category',  [FinanceController::class, 'createCategory']);
    Route::get('/categories', [FinanceController::class, 'getCategories']);

    Route::post('/export', [FinanceController::class, 'exportFinanceData']);
    Route::post('/import', [FinanceController::class, 'importFinanceData']);
});
