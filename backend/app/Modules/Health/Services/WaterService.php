<?php

namespace App\Modules\Health\Services;

use App\Models\UserWaterProgress;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;

class WaterService implements WaterServiceInterface
{
    public function calculateDailyGoal(WaterGoalDTO $data): array
    {
        $goalMultiplier = $data->goal === 'lose_weight' ? 40 : 30;
        $dailyGoalMl    = $data->weight * $goalMultiplier;

        $dailyGoalMl = ceil($dailyGoalMl / $data->glass_volume_ml) * $data->glass_volume_ml;

        $userId = Auth::id();

        UserWaterProgress::updateOrCreate(
            ['user_id' => $userId, 'date' => Carbon::today()],
            [
                'daily_goal_ml'   => $dailyGoalMl,
                'glass_volume_ml' => $data->glass_volume_ml,
            ]
        );

        return [
            'daily_goal_ml'       => $dailyGoalMl,
            'glass_volume_ml'     => $data->glass_volume_ml,
            'recommended_glasses' => $dailyGoalMl / $data->glass_volume_ml,
        ];
    }

    public function addGlass(int $userId): array
    {
        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->first();

        $progress->increment('consumed_ml', $progress->glass_volume_ml);

        $remainingMl = max(0, $progress->daily_goal_ml - $progress->consumed_ml);
        $progress->update(['remaining_ml' => $remainingMl]);

        return [
            'status' => HttpStatusCodes::OK,
            'data'   => [
                'message' => 'Стакан добавлен!',
                'data'    => [
                    'consumed_ml'   => $progress->consumed_ml,
                    'daily_goal_ml' => $progress->daily_goal_ml,
                    'remaining_ml'  => $progress->remaining_ml,
                ],
            ],
        ];
    }

    public function getDailyStats(int $userId): array
    {
        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->first();

        return [
            'status' => HttpStatusCodes::OK,
            'data'   => [
                'daily_goal_ml' => $progress->daily_goal_ml,
                'consumed_ml'   => $progress->consumed_ml,
                'remaining_ml'  => $progress->remaining_ml,
                'glasses_drunk' => $progress->consumed_ml / $progress->glass_volume_ml,
            ],
        ];
    }

    public function getOverallStats(int $userId): array
    {
        $progressStats = UserWaterProgress::where('user_id', $userId)->get();

        $totalMl = $progressStats->sum('consumed_ml');
        $totalGlasses = $progressStats->sum(function ($progress) {
            return $progress->consumed_ml / $progress->glass_volume_ml;
        });

        return [
            'status' => HttpStatusCodes::OK,
            'data'   => [
                'total_ml'      => $totalMl,
                'total_glasses' => $totalGlasses,
            ],
        ];
    }
}
