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
            if (!isset($weeklySummary[$entry->date])) {
                $weeklySummary[$entry->date] = [
                    'calories' => 0,
                    'protein' => 0,
                    'fat' => 0,
                    'carbohydrates' => 0,
                ];
            }
            $weeklySummary[$entry->date]['calories'] += $nutrients['calories'];
            $weeklySummary[$entry->date]['protein'] += $nutrients['protein'];
            $weeklySummary[$entry->date]['fat'] += $nutrients['fat'];
            $weeklySummary[$entry->date]['carbohydrates'] += $nutrients['carbohydrates'];
        }

        return $weeklySummary;
    }
}
