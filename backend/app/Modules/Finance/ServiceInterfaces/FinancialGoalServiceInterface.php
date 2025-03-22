<?php

namespace App\Modules\Finance\ServiceInterfaces;

use App\Models\FinanceGoal;

interface FinancialGoalServiceInterface
{
    public function createGoal(
        int $userId,
        string $name,
        float $targetAmount,
        string $targetDate,
        float $currentAmount,
        ?string $description,
        string $priority
    ): array;

    public function getGoals(
        int $userId,
        string $status,
        ?string $priority
    ): array;

    public function getGoalByIdAndUser(int $id, int $userId): ?FinanceGoal;

    public function updateProgress(int $id, float $amount): array;
}
