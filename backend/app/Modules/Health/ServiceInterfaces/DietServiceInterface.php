<?php

namespace App\Modules\Health\ServiceInterfaces;

interface DietServiceInterface
{
    public function addFood(array $data);
    public function getDailyDiet($date, $mealType = null);
    public function getWeeklyDiet($date = null);
    public function getMonthlyDiet($year, $month);
    public function getStatistics($period);
    public function updateFood($id, array $data);
    public function deleteFood($id);
    public function getDietGoals();
    public function updateDietGoals(array $data);
}
