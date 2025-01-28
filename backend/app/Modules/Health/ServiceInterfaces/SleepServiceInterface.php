<?php

namespace App\Modules\Health\ServiceInterfaces;

interface SleepServiceInterface
{
    public function recordSleep(array $data): array;
    public function analyzeSleep(int $durationInMinutes, array $interruptions): string;
    public function getRecommendations(): array;
}
