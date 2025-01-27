<?php

namespace App\Modules\Health\ServiceInterfaces;

use App\Modules\Health\DTO\WaterGoalDTO;

interface WaterServiceInterface{
    public function calculateDailyGoal(WaterGoalDTO $data): array;
    public function addGlass(int $userId): array;
    public function getDailyStats(int $userId): array;
    public function getOverallStats(int $userId): array;
    public function getWeeklyConsumption(int $userId): array;
    public function getDailyConsumption(int $userId): array;
    public function getMonthlyConsumption(int $userId): array;
}
