<?php

namespace App\Modules\Health\Services;

use App\Models\DietEntry;
use App\Models\DietGoal;
use App\Models\Food;
use App\Modules\Health\Helpers\DietHelper;
use App\Modules\Health\ServiceInterfaces\DietServiceInterface;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class DietService implements DietServiceInterface
{
    public function __construct(
        protected DietHelper $dietHelper
    ) {
    }

    public function addFood(array $data)
    {
        $dietEntry = DietEntry::create([
            'user_id'   => Auth::id(),
            'food_id'   => $data['food_id'],
            'quantity'  => $data['quantity'],
            'date'      => $data['date'],
            'meal_type' => $data['meal_type'],
        ]);

        return $dietEntry->calculateNutrients();
    }

    public function getDailyDiet($date, $mealType = null): array
    {
        $query = DietEntry::where('user_id', Auth::id())
            ->where('date', $date)
            ->with('food');

        if ($mealType) {
            $query->where('meal_type', $mealType);
        }

        $dietEntries = $query->get();
        $dietGoal    = $this->getDietGoals();
        $total       = $this->dietHelper->calculateTotals($dietEntries);

        $remaining = [
            'calories'      => max(0, $dietGoal['calories'] - $total['calories']),
            'protein'       => max(0, $dietGoal['protein'] - $total['protein']),
            'fat'           => max(0, $dietGoal['fat'] - $total['fat']),
            'carbohydrates' => max(0, $dietGoal['carbohydrates'] - $total['carbohydrates']),
        ];

        $progress = [
            'calories'      => $dietGoal['calories'] > 0 ? min(100, round($total['calories'] / $dietGoal['calories'] * 100)) : 0,
            'protein'       => $dietGoal['protein'] > 0 ? min(100, round($total['protein'] / $dietGoal['protein'] * 100)) : 0,
            'fat'           => $dietGoal['fat'] > 0 ? min(100, round($total['fat'] / $dietGoal['fat'] * 100)) : 0,
            'carbohydrates' => $dietGoal['carbohydrates'] > 0 ? min(100, round($total['carbohydrates'] / $dietGoal['carbohydrates'] * 100)) : 0,
        ];

        return [
            'date'      => $date,
            'goal'      => $dietGoal,
            'total'     => $total,
            'remaining' => $remaining,
            'progress'  => $progress,
            'entries'   => $dietEntries->map->calculateNutrients()
        ];
    }

    public function getWeeklyDiet($date = null): array
    {
        $currentDate = $date ? Carbon::parse($date) : Carbon::now();
        $startDate   = $currentDate->copy()->startOfWeek();
        $endDate     = $currentDate->copy()->endOfWeek();

        $dietEntries = DietEntry::where('user_id', Auth::id())
            ->whereBetween('date', [$startDate, $endDate])
            ->with('food')
            ->get();

        $dietGoal      = $this->getDietGoals();
        $weeklySummary = $this->dietHelper->calculateWeeklySummary($dietEntries);

        foreach ($weeklySummary as &$daySummary) {
            $daySummary['goal'] = $dietGoal;
            $daySummary['progress'] = [
                'calories'      => $dietGoal['calories'] > 0 ? min(100, round($daySummary['calories'] / $dietGoal['calories'] * 100)) : 0,
                'protein'       => $dietGoal['protein'] > 0 ? min(100, round($daySummary['protein'] / $dietGoal['protein'] * 100)) : 0,
                'fat'           => $dietGoal['fat'] > 0 ? min(100, round($daySummary['fat'] / $dietGoal['fat'] * 100)) : 0,
                'carbohydrates' => $dietGoal['carbohydrates'] > 0 ? min(100, round($daySummary['carbohydrates'] / $dietGoal['carbohydrates'] * 100)) : 0,
            ];
        }

        return $weeklySummary;
    }

    public function getMonthlyDiet($year, $month): array
    {
        $startDate = Carbon::createFromDate($year, $month, 1)->startOfMonth();
        $endDate   = $startDate->copy()->endOfMonth();

        $dietEntries = DietEntry::where('user_id', Auth::id())
            ->whereBetween('date', [$startDate, $endDate])
            ->with('food')
            ->get();

        $dietGoal       = $this->getDietGoals();
        $dailySummaries = $this->dietHelper->calculateDailySummaries($dietEntries);

        $daysCount = count($dailySummaries);
        $average = [
            'calories'      => 0,
            'protein'       => 0,
            'fat'           => 0,
            'carbohydrates' => 0,
        ];

        if ($daysCount > 0) {
            foreach ($dailySummaries as $day) {
                $average['calories']      += $day['total']['calories'];
                $average['protein']       += $day['total']['protein'];
                $average['fat']           += $day['total']['fat'];
                $average['carbohydrates'] += $day['total']['carbohydrates'];
            }

            $average['calories']      = round($average['calories'] / $daysCount);
            $average['protein']       = round($average['protein'] / $daysCount, 1);
            $average['fat']           = round($average['fat'] / $daysCount, 1);
            $average['carbohydrates'] = round($average['carbohydrates'] / $daysCount, 1);
        }

        return [
            'year'    => (int)$year,
            'month'   => (int)$month,
            'average' => $average,
            'days'    => $dailySummaries
        ];
    }

    public function getStatistics($period): array
    {
        $startDate = $this->getStartDateForPeriod($period);
        $endDate = Carbon::now();

        $dietEntries = DietEntry::where('user_id', Auth::id())
            ->whereBetween('date', [$startDate, $endDate])
            ->with('food')
            ->get();

        $dietGoal       = $this->getDietGoals();
        $dailySummaries = $this->dietHelper->calculateDailySummaries($dietEntries);

        $goalAchievedDays = 0;
        $totalDays        = count($dailySummaries);

        foreach ($dailySummaries as $day) {
            if ($day['goal_achieved']) {
                $goalAchievedDays++;
            }
        }

        $successRate = $totalDays > 0 ? round(($goalAchievedDays / $totalDays) * 100, 1) : 0;

        $average = [
            'calories'      => 0,
            'protein'       => 0,
            'fat'           => 0,
            'carbohydrates' => 0,
        ];

        if ($totalDays > 0) {
            foreach ($dailySummaries as $day) {
                $average['calories']      += $day['total']['calories'];
                $average['protein']       += $day['total']['protein'];
                $average['fat']           += $day['total']['fat'];
                $average['carbohydrates'] += $day['total']['carbohydrates'];
            }

            $average['calories']      = round($average['calories'] / $totalDays);
            $average['protein']       = round($average['protein'] / $totalDays, 1);
            $average['fat']           = round($average['fat'] / $totalDays, 1);
            $average['carbohydrates'] = round($average['carbohydrates'] / $totalDays, 1);
        }

        $progress = [
            'calories'      => [],
            'protein'       => [],
            'fat'           => [],
            'carbohydrates' => [],
        ];

        foreach ($dailySummaries as $day) {
            $progress['calories'][]      = $day['progress']['calories'];
            $progress['protein'][]       = $day['progress']['protein'];
            $progress['fat'][]           = $day['progress']['fat'];
            $progress['carbohydrates'][] = $day['progress']['carbohydrates'];
        }

        $mostFrequentFoods = DB::table('diet_entries')
            ->join('food', 'diet_entries.food_id', '=', 'food.id')
            ->where('diet_entries.user_id', Auth::id())
            ->whereBetween('diet_entries.date', [$startDate, $endDate])
            ->select('food.name', DB::raw('COUNT(*) as count'))
            ->groupBy('food.name')
            ->orderBy('count', 'desc')
            ->limit(5)
            ->get()
            ->toArray();

        return [
            'period'              => $period,
            'goal_achieved_days'  => $goalAchievedDays,
            'total_days'          => $totalDays,
            'success_rate'        => $successRate,
            'average'             => $average,
            'progress'            => $progress,
            'most_frequent_foods' => $mostFrequentFoods
        ];
    }

    protected function getStartDateForPeriod($period): Carbon
    {
        $now = Carbon::now();

        return match ($period) {
            'week'    => $now->copy()->subWeek(),
            'month'   => $now->copy()->subMonth(),
            'quarter' => $now->copy()->subMonths(3),
            'year'    => $now->copy()->subYear(),
            default   => $now->copy()->subMonth(),
        };
    }

    public function updateFood($id, array $data)
    {
        $dietEntry = DietEntry::where('user_id', Auth::id())
            ->where('id', $id)
            ->firstOrFail();

        $dietEntry->update($data);
        $dietEntry->refresh();

        return $dietEntry->calculateNutrients();
    }

    public function deleteFood($id): bool
    {
        $dietEntry = DietEntry::where('user_id', Auth::id())
            ->where('id', $id)
            ->firstOrFail();

        return $dietEntry->delete();
    }

    public function getDietGoals(): array
    {
        $dietGoal = DietGoal::where('user_id', Auth::id())
            ->where('is_active', true)
            ->first();

        if (!$dietGoal) {
            return [
                'calories'      => 2000,
                'protein'       => 100,
                'fat'           => 70,
                'carbohydrates' => 250,
            ];
        }

        return [
            'calories'      => $dietGoal->calories,
            'protein'       => $dietGoal->protein,
            'fat'           => $dietGoal->fat,
            'carbohydrates' => $dietGoal->carbohydrates,
        ];
    }

    public function updateDietGoals(array $data): array
    {
        DietGoal::where('user_id', Auth::id())
            ->where('is_active', true)
            ->update(['is_active' => false]);

        $dietGoal = DietGoal::create([
            'user_id'       => Auth::id(),
            'calories'      => $data['calories'],
            'protein'       => $data['protein'],
            'fat'           => $data['fat'],
            'carbohydrates' => $data['carbohydrates'],
            'is_active'     => true,
        ]);

        return [
            'calories'      => $dietGoal->calories,
            'protein'       => $dietGoal->protein,
            'fat'           => $dietGoal->fat,
            'carbohydrates' => $dietGoal->carbohydrates,
        ];
    }
}
