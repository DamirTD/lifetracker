<?php

namespace App\Modules\Health\DTO;

class WaterReminderDTO
{
    public function __construct(
    public ?int $id,
    public string $start_time,
    public string $end_time,
    public int $interval_minutes,
    public ?array $days_of_week = null,
    public ?bool $is_enabled = true,
    public ?string $message = null
) {
}
}
