<?php

namespace App\Modules\Finance\ServiceInterfaces;

use App\Models\Budget;

interface BudgetServiceInterface
{
    /**
     * @param int $userId
     * @param int $categoryId
     * @param float $amount
     * @param string $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @return Budget
     */
    public function createOrUpdate(
        int $userId,
        int $categoryId,
        float $amount,
        string $period,
        ?string $startDate,
        ?string $endDate
    ): Budget;

    /**
     * @param int $userId
     * @param string|null $period
     * @param int|null $categoryId
     * @return array
     */
    public function getBudgets(
        int $userId,
        ?string $period,
        ?int $categoryId
    ): array;
}
