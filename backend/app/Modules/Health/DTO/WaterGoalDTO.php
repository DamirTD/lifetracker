<?php

namespace App\Modules\Health\DTO;

class WaterGoalDTO
{
    public float $weight;
    public float $height;
    public string $goal;
    public int $glass_volume_ml;

    public function __construct(
        float $weight, float $height, string $goal, int $glass_volume_ml
    )
    {
        $this->weight          = $weight;
        $this->height          = $height;
        $this->goal            = $goal;
        $this->glass_volume_ml = $glass_volume_ml;
    }
}
