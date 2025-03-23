<?php

namespace App\Modules\Health\DTO;

class WaterGoalDTO
{
    public function __construct(
        public int $weight,
        public int $height,
        public ?string $goal = null,
        public ?int $glass_volume_ml = null,
        public ?string $activity_level = null,
        public ?string $climate = null
    ) {
    }
}
