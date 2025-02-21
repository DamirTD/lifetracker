<?php

use App\Modules\Finance\Controllers\FinanceController;
use App\Modules\Finance\Controllers\KaspiBankController;
use Illuminate\Support\Facades\Route;

Route::post('/import-pdf', [KaspiBankController::class, 'importPdf']);
Route::post('/analyze',    [KaspiBankController::class, 'analyze']);

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/finance/calculate',  [FinanceController::class, 'calculateFinance']);
    Route::post('/finance/record',     [FinanceController::class, 'storeFinanceRecord']);
    Route::get('/finance/records',     [FinanceController::class, 'getFinanceRecords']);
    Route::put('/finance/record/{id}', [FinanceController::class, 'updateFinanceRecord']);
});
