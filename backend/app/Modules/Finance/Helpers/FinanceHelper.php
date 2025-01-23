<?php

namespace App\Modules\Finance\Helpers;

class FinanceHelper
{
    public static function getPercentages(string $rule): array
    {
        return match ($rule) {
            '70-20-10' => ['essentials' => 0.70, 'wants' => 0.20, 'savings' => 0.10],
            '60-20-20' => ['essentials' => 0.60, 'wants' => 0.20, 'savings' => 0.20],
            default    => ['essentials' => 0.50, 'wants' => 0.30, 'savings' => 0.20],
        };
    }
}
