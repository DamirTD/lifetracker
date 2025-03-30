<?php

namespace App\Modules\Health\ServiceInterfaces;

interface SleepServiceInterface
{
    public function recordSleep(array $data): array;
    public function analyzeSleep(int $durationInMinutes, array $interruptions, ?string $moodOnWaking = null, ?array $environment = null): string;
    public function getRecommendations(): array;
    public function getStatistics(string $period): array;
    public function getTrends(int $months): array;
    public function setSleepGoals(array $goals): array;
    public function getGoalsProgress(): array;
    public function importDeviceData(array $data): array;
    public function getSleepCorrelations(): array;
}
