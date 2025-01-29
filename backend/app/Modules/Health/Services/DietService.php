<?php

namespace App\Modules\Health\Services;

use App\Models\DietEntry;
use App\Modules\Health\Helpers\DietHelper;
use App\Modules\Health\ServiceInterfaces\DietServiceInterface;
use Illuminate\Support\Facades\Auth;

class DietService implements DietServiceInterface
{

    public function __construct(
        protected DietHelper $dietHelper
    ){
    }

    public function addFood(array $data)
    {
        $dietEntry = DietEntry::create([
            'user_id'  => Auth::id(),
            'food_id'  => $data['food_id'],
            'quantity' => $data['quantity'],
            'date'     => $data['date'],
        ]);

        return $dietEntry->calculateNutrients();
    }

    public function getDailyDiet($date): array
    {
        $dietEntries = DietEntry::where('user_id', Auth::id())
            ->where('date', $date)
            ->with('food')
            ->get();

        $total = $this->dietHelper->calculateTotals($dietEntries);

        return [
            'date'    => $date,
            'total'   => $total,
            'entries' => $dietEntries
        ];
    }

    public function getWeeklyDiet(): array
    {
        $startDate = now()->subDays(7);
        $dietEntries = DietEntry::where('user_id', Auth::id())
            ->where('date', '>=', $startDate)
            ->with('food')
            ->get();

        return $this->dietHelper->calculateWeeklySummary($dietEntries);
    }
}
