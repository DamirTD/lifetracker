<?php

namespace App\Modules\Health\ServiceInterfaces;

interface DietServiceInterface
{
    public function addFood(array $data);
    public function getDailyDiet($date, $mealType = null);
    public function getWeeklyDiet();
    public function updateFood($id, array $data);
    public function deleteFood($id);
}
