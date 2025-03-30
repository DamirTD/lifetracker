<?php

namespace App\Modules\Health\Helpers;

use App\Http\Controllers\Controller;

class DietHelper extends Controller
{
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
}
