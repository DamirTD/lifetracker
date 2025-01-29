<?php

namespace App\Modules\Health\ServiceInterfaces;

interface DietServiceInterface
{
    public function addFood(array $data);
    public function getDailyDiet($date);
    public function getWeeklyDiet();
}
