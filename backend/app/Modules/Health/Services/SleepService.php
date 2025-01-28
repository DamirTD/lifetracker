<?php

namespace App\Modules\Health\Services;

use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use Carbon\Carbon;

class SleepService implements SleepServiceInterface
{
    public function __construct(protected SleepRepositoryInterface $sleepRepository
    ){
    }

    public function recordSleep(array $data): array
    {
        $bedtime    = Carbon::createFromTimeString($data['bedtime']);
        $wakeUpTime = Carbon::createFromTimeString($data['wake_up_time']);

        if ($bedtime->greaterThan($wakeUpTime)) {
            $wakeUpTime->addDay();
        }

        $sleepDuration = $bedtime->diffInMinutes($wakeUpTime);
        $sleepQuality = $this->analyzeSleep($sleepDuration, $data['interruptions'] ?? []);

        return $this->sleepRepository->create([
            'user_id' => auth()->id(),
            'bedtime' => $data['bedtime'],
            'wake_up_time' => $data['wake_up_time'],
            'interruptions' => $data['interruptions'] ?? [],
            'duration' => $sleepDuration,
            'quality' => $sleepQuality,
        ]);
    }

    public function analyzeSleep(int $durationInMinutes, array $interruptions): string
    {
        $hours = floor($durationInMinutes / 60);
        $interruptionsCount = count($interruptions);

        if ($hours < 5) {
            return 'Критически недостаточный сон';
        } elseif ($hours < 6) {
            return 'Недостаточный сон';
        } elseif ($hours < 8 && $interruptionsCount <= 1) {
            return 'Хороший сон';
        } elseif ($hours >= 8 && $interruptionsCount == 0) {
            return 'Отличный сон';
        } else {
            return 'Средний сон';
        }
    }

    public function getRecommendations(): array
    {
        return [
            'Соблюдайте режим сна: ложитесь и просыпайтесь в одно и то же время каждый день.',
            'Создайте идеальную обстановку для сна: выключите свет, шум, поддерживайте прохладную температуру.',
            'Избегайте использования гаджетов за 2 часа до сна.',
            'Не употребляйте кофе или алкоголь за 6 часов до сна.',
            'Занимайтесь физической активностью, но не поздно вечером.',
            'Попробуйте дыхательные техники или медитацию для расслабления перед сном.',
        ];
    }
}
