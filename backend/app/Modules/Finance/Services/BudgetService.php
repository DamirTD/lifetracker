<?php

namespace App\Modules\Finance\Services;

use App\Models\Budget;
use App\Models\FinanceRecord;
use App\Modules\Finance\ServiceInterfaces\BudgetServiceInterface;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use Carbon\Carbon;

class BudgetService implements BudgetServiceInterface
{
    public function __construct(
        protected FinanceRecordQueryInterface $recordQuery
    ) {
    }

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
    ): Budget
    {
        if (!$startDate || !$endDate) {
            list($startDate, $endDate) = $this->getDateRangeForPeriod($period);
        }

        $budget = Budget::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('period', $period)
            ->where('start_date', $startDate)
            ->where('end_date', $endDate)
            ->first();

        if ($budget) {
            $budget->amount = $amount;
            $budget->save();
        } else {
            $budget = Budget::create([
                'user_id'     => $userId,
                'category_id' => $categoryId,
                'amount'      => $amount,
                'period'      => $period,
                'start_date'  => $startDate,
                'end_date'    => $endDate
            ]);
        }

        return $budget;
    }

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
    ): array {
        $query = Budget::where('user_id', $userId)
            ->with('category');

        if ($period) {
            $query->where('period', $period);
        }

        if ($categoryId) {
            $query->where('category_id', $categoryId);
        }

        $budgets = $query->get();
        $result = [];

        foreach ($budgets as $budget) {
            $spent = $this->getSpentAmountForBudget($userId, $budget->category_id, $budget->start_date, $budget->end_date);

            $remaining      = $budget->amount - $spent;
            $percentageUsed = $budget->amount > 0 ? ($spent / $budget->amount) * 100 : 0;

            $result[] = [
                'id'              => $budget->id,
                'category_id'     => $budget->category_id,
                'category_name'   => $budget->category->name,
                'amount'          => round($budget->amount, 2),
                'spent'           => round($spent, 2),
                'remaining'       => round($remaining, 2),
                'percentage_used' => round($percentageUsed, 2),
                'period'          => $budget->period,
                'start_date'      => $budget->start_date->format('Y-m-d'),
                'end_date'        => $budget->end_date->format('Y-m-d')
            ];
        }

        return $result;
    }

    /**
     * @param string $period
     * @return array
     */
    private function getDateRangeForPeriod(string $period): array
    {
        $now = Carbon::now();

        return match ($period) {
            'week'  => [$now->startOfWeek()->format('Y-m-d'), $now->endOfWeek()->format('Y-m-d')],
            'year'  => [$now->startOfYear()->format('Y-m-d'), $now->endOfYear()->format('Y-m-d')],
            default => [$now->startOfMonth()->format('Y-m-d'), $now->endOfMonth()->format('Y-m-d')],
        };
    }

    /**
     * @param int $userId
     * @param int $categoryId
     * @param string $startDate
     * @param string $endDate
     * @return float
     */
    private function getSpentAmountForBudget(int $userId, int $categoryId, string $startDate, string $endDate): float
    {
        $records = FinanceRecord::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('type', 'expense')
            ->whereBetween('date', [$startDate, $endDate])
            ->get();

        return $records->sum('amount');
    }
}
