<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\ServiceInterfaces\FinanceStatisticsServiceInterface;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class FinanceStatisticsService implements FinanceStatisticsServiceInterface
{
    public function __construct(
        protected FinanceRecordQueryInterface $recordQuery
    ) {
    }

    /**
     * @param int $userId
     * @param string|null $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @return array
     */
    public function getSummary(int $userId, ?string $period, ?string $startDate, ?string $endDate): array
    {
        list($start, $end) = $this->getDateRange($period, $startDate, $endDate);

        $records = DB::table('finance_records')
            ->where('user_id', $userId)
            ->whereBetween('date', [$start, $end])
            ->get();

        $totalIncome     = $records->where('type', 'income')->sum('amount');
        $totalExpense    = $records->where('type', 'expense')->sum('amount');
        $totalSaving     = $records->where('type', 'saving')->sum('amount');
        $totalInvestment = $records->where('type', 'investment')->sum('amount');

        $balance = $totalIncome - $totalExpense - $totalSaving - $totalInvestment;

        return [
            'total_income'     => round($totalIncome, 2),
            'total_expense'    => round($totalExpense, 2),
            'total_saving'     => round($totalSaving, 2),
            'total_investment' => round($totalInvestment, 2),
            'balance'          => round($balance, 2)
        ];
    }

    /**
     * @param int $userId
     * @param string $period
     * @param string|null $type
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $groupBy
     * @return array
     */
    public function getStatistics(
        int $userId,
        string $period,
        ?string $type,
        ?string $startDate,
        ?string $endDate,
        string $groupBy
    ): array {
        list($start, $end) = $this->getDateRange($period, $startDate, $endDate);

        $previousPeriodLength = Carbon::parse($end)->diffInDays(Carbon::parse($start));
        $previousStart = Carbon::parse($start)->subDays($previousPeriodLength)->format('Y-m-d');
        $previousEnd = Carbon::parse($start)->subDays(1)->format('Y-m-d');

        $query = DB::table('finance_records')
            ->where('user_id', $userId)
            ->whereBetween('date', [$start, $end]);

        if ($type) {
            $query->where('type', $type);
        }

        $records = $query->get();

        $previousQuery = DB::table('finance_records')
            ->where('user_id', $userId)
            ->whereBetween('date', [$previousStart, $previousEnd]);

        if ($type) {
            $previousQuery->where('type', $type);
        }

        $previousRecords = $previousQuery->get();

        $summary = $this->calculateSummary($records);
        $previousSummary = $this->calculateSummary($previousRecords);

        $trends = $this->calculateTrends($summary, $previousSummary);

        $data = [];
        if ($groupBy === 'category') {
            $data = $this->groupByCategory($records, $userId);
        } else {
            $data = $this->groupByTimePeriod($records, $groupBy);
        }

        $categoryBreakdown = $this->createCategoryBreakdown($records, $userId);

        return [
            'summary'            => $summary,
            'data'               => $data,
            'trends'             => $trends,
            'category_breakdown' => $categoryBreakdown
        ];
    }

    /**
     * @param string|null $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @return array
     */
    private function getDateRange(?string $period, ?string $startDate, ?string $endDate): array
    {
        $now = Carbon::now();

        if ($period === 'custom' && $startDate && $endDate) {
            return [$startDate, $endDate];
        }

        return match ($period) {
            'day'  => [$now->format('Y-m-d'), $now->format('Y-m-d')],
            'week'  => [$now->startOfWeek()->format('Y-m-d'), $now->endOfWeek()->format('Y-m-d')],
            'year'  => [$now->startOfYear()->format('Y-m-d'), $now->endOfYear()->format('Y-m-d')],
            default => [$now->startOfMonth()->format('Y-m-d'), $now->endOfMonth()->format('Y-m-d')],
        };
    }

    /**
     * @param Collection $records
     * @return array
     */
    private function calculateSummary($records): array
    {
        $totalIncome     = $records->where('type', 'income')->sum('amount');
        $totalExpense    = $records->where('type', 'expense')->sum('amount');
        $totalSaving     = $records->where('type', 'saving')->sum('amount');
        $totalInvestment = $records->where('type', 'investment')->sum('amount');

        $balance = $totalIncome - $totalExpense - $totalSaving - $totalInvestment;

        $savingRate  = $totalIncome > 0 ? ($totalSaving / $totalIncome) * 100 : 0;
        $expenseRate = $totalIncome > 0 ? ($totalExpense / $totalIncome) * 100 : 0;

        return [
            'total_income'     => round($totalIncome, 2),
            'total_expense'    => round($totalExpense, 2),
            'total_saving'     => round($totalSaving, 2),
            'total_investment' => round($totalInvestment, 2),
            'balance'          => round($balance, 2),
            'saving_rate'      => round($savingRate, 2),
            'expense_rate'     => round($expenseRate, 2)
        ];
    }

    /**
     * @param array $current
     * @param array $previous
     * @return array
     */
    private function calculateTrends(array $current, array $previous): array
    {
        $calculateTrend = function ($currentValue, $previousValue) {
            if ($previousValue == 0) return 0;
            return round((($currentValue - $previousValue) / $previousValue) * 100, 2);
        };

        return [
            'income_trend'     => $calculateTrend($current['total_income'], $previous['total_income']),
            'expense_trend'    => $calculateTrend($current['total_expense'], $previous['total_expense']),
            'saving_trend'     => $calculateTrend($current['total_saving'], $previous['total_saving']),
            'investment_trend' => $calculateTrend($current['total_investment'], $previous['total_investment'])
        ];
    }

    /**
     * @param Collection $records
     * @param string $groupBy
     * @return array
     */
    private function groupByTimePeriod(Collection $records, string $groupBy): array
    {
        $result = [];

        $format = match ($groupBy) {
            'week'  => 'W (Y)',
            'month' => 'F Y',
            'year'  => 'Y',
            default => 'Y-m-d',
        };

        $grouped = $records->groupBy(function ($item) use ($format) {
            return Carbon::parse($item->date)->format($format);
        });

        foreach ($grouped as $period => $items) {
            $result[] = [
                'period' => $period,
                'amount' => round($items->sum('amount'), 2),
                'count'  => $items->count()
            ];
        }

        return $result;
    }

    /**
     * @param Collection $records
     * @param int $userId
     * @return array
     */
    private function groupByCategory(Collection $records, int $userId): array
    {
        $result     = [];
        $categories = DB::table('finance_categories')->where('user_id', $userId)->get()->keyBy('id');

        $grouped = $records->groupBy('category_id');

        foreach ($grouped as $categoryId => $items) {
            $categoryName = $categories->get($categoryId)->name ?? 'Без категории';

            $result[] = [
                'period' => $categoryName,
                'amount' => round($items->sum('amount'), 2),
                'count'  => $items->count()
            ];
        }

        return $result;
    }

    /**
     * @param Collection $records
     * @param int $userId
     * @return array
     */
    private function createCategoryBreakdown(Collection $records, int $userId): array
    {
        $result = [];
        $categories = DB::table('finance_categories')->where('user_id', $userId)->get()->keyBy('id');

        $totalAmount = $records->sum('amount');
        $grouped     = $records->groupBy('category_id');

        foreach ($grouped as $categoryId => $items) {
            $category = $categories->get($categoryId);
            if (!$category) continue;

            $amount     = $items->sum('amount');
            $percentage = $totalAmount > 0 ? ($amount / $totalAmount) * 100 : 0;

            $result[] = [
                'category_id'   => $categoryId,
                'category_name' => $category->name,
                'amount'        => round($amount, 2),
                'percentage'    => round($percentage, 2)
            ];
        }

        usort($result, function ($a, $b) {
            return $b['amount'] <=> $a['amount'];
        });

        return $result;
    }
}
