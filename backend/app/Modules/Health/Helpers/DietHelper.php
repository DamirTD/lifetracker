<?php

namespace App\Modules\Health\Helpers;

use App\Http\Controllers\Controller;
use App\Models\DietGoal;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;

class DietHelper extends Controller
{
    /**
     * Расчет суммарных значений питательных веществ
     *
     * @param \Illuminate\Database\Eloquent\Collection $entries
     * @return array
     */
    public function calculateTotals($entries): array
    {
        $total = [
            'calories'      => 0,
            'protein'       => 0,
            'fat'           => 0,
            'carbohydrates' => 0,
        ];

        foreach ($entries as $entry) {
            $nutrients = $entry->calculateNutrients();
            $total['calories']      += $nutrients['calories'];
            $total['protein']       += $nutrients['protein'];
            $total['fat']           += $nutrients['fat'];
            $total['carbohydrates'] += $nutrients['carbohydrates'];
        }

        return $total;
    }

    /**
     * Расчет суммарных значений по дням недели
     *
     * @param \Illuminate\Database\Eloquent\Collection $entries
     * @return array
     */
    public function calculateWeeklySummary($entries): array
    {
        $weeklySummary = [];

        foreach ($entries as $entry) {
            $nutrients = $entry->calculateNutrients();
            // Преобразуем объект даты в строку Y-m-d
            $dateKey = $entry->date->format('Y-m-d');

            if (!isset($weeklySummary[$dateKey])) {
                $weeklySummary[$dateKey] = [
                    'date' => $dateKey,
                    'calories' => 0,
                    'protein' => 0,
                    'fat' => 0,
                    'carbohydrates' => 0,
                ];
            }

            $weeklySummary[$dateKey]['calories'] += $nutrients['calories'];
            $weeklySummary[$dateKey]['protein'] += $nutrients['protein'];
            $weeklySummary[$dateKey]['fat'] += $nutrients['fat'];
            $weeklySummary[$dateKey]['carbohydrates'] += $nutrients['carbohydrates'];
        }

        // Преобразуем ассоциативный массив в обычный массив
        return array_values($weeklySummary);
    }

    /**
     * Расчет детальной сводки по дням с проверкой достижения целей
     *
     * @param \Illuminate\Database\Eloquent\Collection $entries
     * @return array
     */
    public function calculateDailySummaries($entries): array
    {
        $dailySummaries = [];
        $dietGoal = $this->getCurrentDietGoal();

        // Группируем записи по дням
        $entriesByDate = $entries->groupBy(function ($entry) {
            return $entry->date->format('Y-m-d');
        });

        foreach ($entriesByDate as $date => $dayEntries) {
            $total = $this->calculateTotals($dayEntries);

            // Расчёт процента достижения цели
            $progress = [
                'calories' => $dietGoal['calories'] > 0 ? min(100, round($total['calories'] / $dietGoal['calories'] * 100)) : 0,
                'protein' => $dietGoal['protein'] > 0 ? min(100, round($total['protein'] / $dietGoal['protein'] * 100)) : 0,
                'fat' => $dietGoal['fat'] > 0 ? min(100, round($total['fat'] / $dietGoal['fat'] * 100)) : 0,
                'carbohydrates' => $dietGoal['carbohydrates'] > 0 ? min(100, round($total['carbohydrates'] / $dietGoal['carbohydrates'] * 100)) : 0,
            ];

            // Определяем, достигнута ли цель
            // Цель считается достигнутой, если калории в пределах 10% от цели и белки >= 90% от цели
            $caloriesLower = $dietGoal['calories'] * 0.9;
            $caloriesUpper = $dietGoal['calories'] * 1.1;
            $proteinThreshold = $dietGoal['protein'] * 0.9;

            $goalAchieved =
                $total['calories'] >= $caloriesLower &&
                $total['calories'] <= $caloriesUpper &&
                $total['protein'] >= $proteinThreshold;

            $dailySummaries[] = [
                'date' => $date,
                'total' => $total,
                'progress' => $progress,
                'goal_achieved' => $goalAchieved
            ];
        }

        // Сортируем по дате
        usort($dailySummaries, function ($a, $b) {
            return strcmp($a['date'], $b['date']);
        });

        return $dailySummaries;
    }

    /**
     * Получить текущую активную цель питания
     *
     * @return array
     */
    private function getCurrentDietGoal(): array
    {
        $dietGoal = DietGoal::where('user_id', Auth::id())
            ->where('is_active', true)
            ->first();

        if (!$dietGoal) {
            // Значения по умолчанию, если цели не установлены
            return [
                'calories' => 2000,
                'protein' => 100,
                'fat' => 70,
                'carbohydrates' => 250,
            ];
        }

        return [
            'calories' => $dietGoal->calories,
            'protein' => $dietGoal->protein,
            'fat' => $dietGoal->fat,
            'carbohydrates' => $dietGoal->carbohydrates,
        ];
    }
}
