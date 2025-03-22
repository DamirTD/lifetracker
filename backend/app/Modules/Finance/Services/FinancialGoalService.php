<?php

namespace App\Modules\Finance\Services;

use App\Models\FinanceGoal;
use App\Modules\Finance\ServiceInterfaces\FinancialGoalServiceInterface;
use Carbon\Carbon;

class FinancialGoalService implements FinancialGoalServiceInterface
{
    public function createGoal(
        int $userId,
        string $name,
        float $targetAmount,
        string $targetDate,
        float $currentAmount,
        ?string $description,
        string $priority
    ): array
    {
        $goal = FinanceGoal::create([
            'user_id' => $userId,
            'name' => $name,
            'target_amount' => $targetAmount,
            'current_amount' => $currentAmount,
            'target_date' => $targetDate,
            'description' => $description,
            'priority' => $priority,
            'status' => 'active'
        ]);

        return $this->formatGoal($goal);
    }

    public function getGoals(
        int $userId,
        string $status,
        ?string $priority
    ): array {
        $query = FinanceGoal::where('user_id', $userId);

        if ($status !== 'all') {
            $query->where('status', $status);
        }

        if ($priority) {
            $query->where('priority', $priority);
        }

        $goals = $query->get();
        $result = [];

        foreach ($goals as $goal) {
            $result[] = $this->formatGoal($goal);
        }

        return $result;
    }

    public function getGoalByIdAndUser(int $id, int $userId): ?FinanceGoal
    {
        return FinanceGoal::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function updateProgress(int $id, float $amount): array
    {
        $goal = FinanceGoal::findOrFail($id);

        $goal->current_amount += $amount;

        if ($goal->current_amount >= $goal->target_amount) {
            $goal->status = 'completed';
        }

        $goal->save();

        return $this->formatGoal($goal);
    }

    private function formatGoal(FinanceGoal $goal): array
    {
        $now = Carbon::now();
        $targetDate = Carbon::parse($goal->target_date);

        $daysRemaining = $now->diffInDays($targetDate, false);
        $daysRemaining = max(0, $daysRemaining);

        $progress = $goal->target_amount > 0 ? ($goal->current_amount / $goal->target_amount) * 100 : 0;

        $amountNeeded       = $goal->target_amount - $goal->current_amount;
        $amountNeededPerDay = $daysRemaining > 0 ? $amountNeeded / $daysRemaining : 0;

        return [
            'id'                    => $goal->id,
            'name'                  => $goal->name,
            'target_amount'         => round($goal->target_amount, 2),
            'current_amount'        => round($goal->current_amount, 2),
            'target_date'           => $goal->target_date->format('Y-m-d'),
            'description'           => $goal->description,
            'priority'              => $goal->priority,
            'status'                => $goal->status,
            'progress'              => round($progress, 2),
            'days_remaining'        => $daysRemaining,
            'amount_needed_per_day' => round($amountNeededPerDay, 2)
        ];
    }
}
