<?php

namespace App\Modules\Health\DTO;

class WaterContainerDTO
{
    public function __construct(
        public ?int $id,
        public string $name,
        public int $volume_ml,
        public ?string $icon = null,
        public ?string $color = null,
        public ?bool $is_default = false
    ) {
    }
}
