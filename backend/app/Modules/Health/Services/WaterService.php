<?php

namespace App\Modules\Health\Services;

use App\Models\UserWaterContainer;
use App\Models\UserWaterProgressHistory;
use App\Models\UserWaterProgress;
use App\Models\UserWaterReminder;
use App\Modules\Health\DTO\WaterContainerDTO;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\DTO\WaterReminderDTO;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class WaterService implements WaterServiceInterface
{
    public function calculateDailyGoal(WaterGoalDTO $data): array
    {
        $baseGoalMl = $data->weight * ($data->goal === 'lose_weight' ? 40 : 30);

        $heightFactor = $data->height > 180 ? 1.1 : ($data->height < 160 ? 0.9 : 1);

        $activityFactor = 1;
        if (isset($data->activity_level)) {
            switch ($data->activity_level) {
                case 'sedentary':
                    $activityFactor = 0.9;
                    break;
                case 'moderate':
                    $activityFactor = 1.1;
                    break;
                case 'active':
                    $activityFactor = 1.3;
                    break;
                case 'very_active':
                    $activityFactor = 1.5;
                    break;
            }
        }

        $climateFactor = 1;
        if (isset($data->climate)) {
            switch ($data->climate) {
                case 'cold':
                    $climateFactor = 0.9;
                    break;
                case 'moderate':
                    $climateFactor = 1;
                    break;
                case 'hot':
                    $climateFactor = 1.2;
                    break;
                case 'very_hot':
                    $climateFactor = 1.4;
                    break;
            }
        }

        $dailyGoalMl = $baseGoalMl * $heightFactor * $activityFactor * $climateFactor;
        $dailyGoalMl = ceil($dailyGoalMl / $data->glass_volume_ml) * $data->glass_volume_ml;

        $userId = Auth::id();

        $progress = UserWaterProgress::updateOrCreate(
            ['user_id' => $userId, 'date' => Carbon::today()],
            [
                'daily_goal_ml' => $dailyGoalMl,
                'glass_volume_ml' => $data->glass_volume_ml,
                'remaining_ml' => $dailyGoalMl,
            ]
        );

        if ($progress->wasRecentlyCreated || $progress->wasChanged('daily_goal_ml')) {
            UserWaterProgressHistory::create([
                'user_id' => $userId,
                'date' => Carbon::today(),
                'daily_goal_ml' => $dailyGoalMl,
                'glass_volume_ml' => $data->glass_volume_ml,
                'calculation_factors' => json_encode([
                    'weight' => $data->weight,
                    'height' => $data->height,
                    'goal' => $data->goal,
                    'activity_level' => $data->activity_level ?? 'moderate',
                    'climate' => $data->climate ?? 'moderate',
                ])
            ]);
        }

        return [
            'daily_goal_ml' => $dailyGoalMl,
            'glass_volume_ml' => $data->glass_volume_ml,
            'recommended_glasses' => $dailyGoalMl / $data->glass_volume_ml,
            'factors' => [
                'weight_factor' => $baseGoalMl / $data->weight,
                'height_factor' => $heightFactor,
                'activity_factor' => $activityFactor,
                'climate_factor' => $climateFactor
            ]
        ];
    }

    public function addGlass(int $userId, ?int $containerId = null, ?int $customVolumeMl = null): array
    {
        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->first();

        if (!$progress) {
            return [
                'status' => HttpStatusCodes::NOT_FOUND,
                'data' => [
                    'message' => 'Прогресс не найден. Создайте запись для текущего дня.',
                ],
            ];
        }

        $volumeMl = $progress->glass_volume_ml;

        if ($containerId) {
            $container = UserWaterContainer::find($containerId);
            if ($container && $container->user_id == $userId) {
                $volumeMl = $container->volume_ml;
            }
        } elseif ($customVolumeMl) {
            $volumeMl = $customVolumeMl;
        }

        UserWaterProgressHistory::create([
            'user_id' => $userId,
            'date' => Carbon::today(),
            'action' => 'add',
            'volume_ml' => $volumeMl,
            'container_id' => $containerId,
            'timestamp' => Carbon::now(),
        ]);

        $progress->increment('consumed_ml', $volumeMl);

        if (!isset($progress->glasses_today)) {
            $progress->glasses_today = 0;
        }
        $progress->increment('glasses_today');

        $remainingMl = max(0, $progress->daily_goal_ml - $progress->consumed_ml);
        $progress->update([
            'remaining_ml' => $remainingMl,
            'last_added_at' => Carbon::now(),
        ]);

        $percentComplete = min(100, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100));

        $achievements = $this->checkAchievements($userId, $progress);

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => 'Стакан добавлен!',
                'consumed_ml' => $progress->consumed_ml,
                'daily_goal_ml' => $progress->daily_goal_ml,
                'remaining_ml' => $progress->remaining_ml,
                'glasses_today' => $progress->glasses_today,
                'glasses_volume_ml' => $progress->glass_volume_ml,
                'last_added_at' => Carbon::now()->toDateTimeString(),
                'percent_complete' => $percentComplete,
                'achievements' => $achievements,
                'next_reminder' => $this->getNextReminder($userId),
            ],
        ];
    }

    public function removeGlass(int $userId): array
    {
        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->first();

        if (!$progress || $progress->consumed_ml <= 0 || $progress->glasses_today <= 0) {
            return [
                'status' => HttpStatusCodes::BAD_REQUEST,
                'data' => [
                    'message' => 'Нет добавленных стаканов воды за сегодня.',
                ],
            ];
        }

        $lastAddition = UserWaterProgressHistory::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->where('action', 'add')
            ->latest('timestamp')
            ->first();

        $volumeToRemove = $lastAddition ? $lastAddition->volume_ml : $progress->glass_volume_ml;

        $progress->decrement('consumed_ml', $volumeToRemove);
        $progress->decrement('glasses_today');

        $remainingMl = max(0, $progress->daily_goal_ml - $progress->consumed_ml);
        $progress->update(['remaining_ml' => $remainingMl]);

        UserWaterProgressHistory::create([
            'user_id' => $userId,
            'date' => Carbon::today(),
            'action' => 'remove',
            'volume_ml' => $volumeToRemove,
            'container_id' => $lastAddition ? $lastAddition->container_id : null,
            'timestamp' => Carbon::now(),
        ]);

        $percentComplete = max(0, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100));

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => 'Стакан удален!',
                'consumed_ml' => $progress->consumed_ml,
                'daily_goal_ml' => $progress->daily_goal_ml,
                'remaining_ml' => $progress->remaining_ml,
                'glasses_today' => $progress->glasses_today,
                'glasses_volume_ml' => $progress->glass_volume_ml,
                'percent_complete' => $percentComplete,
            ],
        ];
    }

    public function getDailyStats(int $userId): array
    {
        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->first();

        if (!$progress) {
            return [
                'status' => HttpStatusCodes::OK,
                'data' => [
                    'message' => 'Нет данных о потреблении воды за сегодня.',
                    'daily_goal_ml' => 0,
                    'consumed_ml' => 0,
                    'remaining_ml' => 0,
                    'glasses_drunk' => 0,
                    'percent_complete' => 0,
                ],
            ];
        }

        $hourlyStats = UserWaterProgressHistory::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->where('action', 'add')
            ->get()
            ->groupBy(function ($item) {
                return Carbon::parse($item->timestamp)->format('H');
            })
            ->map(function ($group) {
                return $group->sum('volume_ml');
            });

        $percentComplete = $progress->daily_goal_ml > 0
            ? min(100, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100))
            : 0;

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'daily_goal_ml' => $progress->daily_goal_ml,
                'consumed_ml' => $progress->consumed_ml,
                'remaining_ml' => $progress->remaining_ml,
                'glasses_drunk' => floor($progress->consumed_ml / $progress->glass_volume_ml),
                'percent_complete' => $percentComplete,
                'hourly_consumption' => $hourlyStats,
                'last_added_at' => $progress->last_added_at,
                'streak' => $this->getUserStreak($userId),
            ],
        ];
    }

    public function getOverallStats(int $userId): array
    {
        $progressStats = UserWaterProgress::where('user_id', $userId)->get();

        $totalMl = $progressStats->sum('consumed_ml');
        $totalDays = $progressStats->count();
        $daysReachedGoal = $progressStats->filter(function ($progress) {
            return $progress->consumed_ml >= $progress->daily_goal_ml;
        })->count();

        $averageConsumptionMl = $totalDays > 0 ? round($totalMl / $totalDays) : 0;
        $successRate = $totalDays > 0 ? round(($daysReachedGoal / $totalDays) * 100) : 0;

        // Получение данных тренда по дням недели
        $dayOfWeekStats = UserWaterProgress::where('user_id', $userId)
            ->get()
            ->groupBy(function ($item) {
                return Carbon::parse($item->date)->dayOfWeek;
            })
            ->map(function ($group) {
                return [
                    'average_ml' => $group->avg('consumed_ml'),
                    'count' => $group->count(),
                ];
            });

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'total_ml' => $totalMl,
                'total_days' => $totalDays,
                'days_reached_goal' => $daysReachedGoal,
                'success_rate' => $successRate,
                'average_daily_ml' => $averageConsumptionMl,
                'day_of_week_stats' => $dayOfWeekStats,
                'current_streak' => $this->getUserStreak($userId),
                'best_streak' => $this->getBestStreak($userId),
                'equivalent_water_bottles' => round($totalMl / 500), // Эквивалент в 500мл бутылках
                'water_saved_vs_bottled' => round($totalMl / 1000 * 2), // кг CO2 сэкономлено
            ],
        ];
    }

    public function getDailyConsumption(int $userId, ?string $date = null): array
    {
        $date = $date ? Carbon::parse($date)->startOfDay() : Carbon::today();

        $progress = UserWaterProgress::where('user_id', $userId)
            ->where('date', $date)
            ->first();

        $hourlyData = UserWaterProgressHistory::where('user_id', $userId)
            ->where('date', $date)
            ->where('action', 'add')
            ->get()
            ->groupBy(function ($item) {
                return Carbon::parse($item->timestamp)->format('H');
            })
            ->map(function ($group) {
                return $group->sum('volume_ml');
            });

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'date' => $date->toDateString(),
                'consumed_ml' => $progress->consumed_ml ?? 0,
                'daily_goal_ml' => $progress->daily_goal_ml ?? 0,
                'percent_complete' => $progress && $progress->daily_goal_ml > 0
                    ? min(100, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100))
                    : 0,
                'hourly_data' => $hourlyData,
            ],
        ];
    }

    public function getWeeklyConsumption(int $userId, ?string $startDate = null): array
    {
        $startOfWeek = $startDate
            ? Carbon::parse($startDate)->startOfWeek()
            : Carbon::now()->startOfWeek();

        $endOfWeek = (clone $startOfWeek)->endOfWeek();

        $dailyData = UserWaterProgress::where('user_id', $userId)
            ->whereBetween('date', [$startOfWeek, $endOfWeek])
            ->orderBy('date')
            ->get()
            ->map(function ($progress) {
                $date = Carbon::parse($progress->date);
                return [
                    'date' => $date->toDateString(),
                    'day_of_week' => $date->dayOfWeekIso,
                    'day_name' => $date->translatedFormat('l'),
                    'consumed_ml' => $progress->consumed_ml,
                    'daily_goal_ml' => $progress->daily_goal_ml,
                    'percent_complete' => $progress->daily_goal_ml > 0
                        ? min(100, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100))
                        : 0,
                ];
            });

        // Заполнение пустых дней нулевыми значениями
        $allDays = [];
        for ($day = 0; $day < 7; $day++) {
            $date = (clone $startOfWeek)->addDays($day);
            $dayData = $dailyData->firstWhere('date', $date->toDateString());

            if (!$dayData) {
                $allDays[] = [
                    'date' => $date->toDateString(),
                    'day_of_week' => $date->dayOfWeekIso,
                    'day_name' => $date->translatedFormat('l'),
                    'consumed_ml' => 0,
                    'daily_goal_ml' => 0,
                    'percent_complete' => 0,
                ];
            } else {
                $allDays[] = $dayData;
            }
        }

        $totalConsumedMl = collect($allDays)->sum('consumed_ml');
        $totalGoalMl = collect($allDays)->sum('daily_goal_ml');
        $weeklyPercentComplete = $totalGoalMl > 0 ? min(100, round(($totalConsumedMl / $totalGoalMl) * 100)) : 0;

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'start_date' => $startOfWeek->toDateString(),
                'end_date' => $endOfWeek->toDateString(),
                'consumed_ml' => $totalConsumedMl,
                'goal_ml' => $totalGoalMl,
                'percent_complete' => $weeklyPercentComplete,
                'daily_data' => $allDays,
                'streak' => $this->getUserStreak($userId),
            ],
        ];
    }

    public function getMonthlyConsumption(int $userId, ?string $yearMonth = null): array
    {
        if ($yearMonth) {
            $date = Carbon::createFromFormat('Y-m', $yearMonth);
            $startOfMonth = $date->copy()->startOfMonth();
            $endOfMonth = $date->copy()->endOfMonth();
        } else {
            $startOfMonth = Carbon::now()->startOfMonth();
            $endOfMonth = Carbon::now()->endOfMonth();
        }

        $dailyData = UserWaterProgress::where('user_id', $userId)
            ->whereBetween('date', [$startOfMonth, $endOfMonth])
            ->orderBy('date')
            ->get()
            ->map(function ($progress) {
                $date = Carbon::parse($progress->date);
                return [
                    'date' => $date->toDateString(),
                    'day' => $date->day,
                    'consumed_ml' => $progress->consumed_ml,
                    'daily_goal_ml' => $progress->daily_goal_ml,
                    'percent_complete' => $progress->daily_goal_ml > 0
                        ? min(100, round(($progress->consumed_ml / $progress->daily_goal_ml) * 100))
                        : 0,
                ];
            });

        $totalConsumedMl = $dailyData->sum('consumed_ml');
        $daysWithData = $dailyData->count();
        $daysReachedGoal = $dailyData->filter(function ($day) {
            return $day['percent_complete'] >= 100;
        })->count();

        $averageDailyConsumption = $daysWithData > 0 ? round($totalConsumedMl / $daysWithData) : 0;
        $successRate = $daysWithData > 0 ? round(($daysReachedGoal / $daysWithData) * 100) : 0;

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'year_month' => $startOfMonth->format('Y-m'),
                'month_name' => $startOfMonth->translatedFormat('F Y'),
                'consumed_ml' => $totalConsumedMl,
                'days_with_data' => $daysWithData,
                'days_reached_goal' => $daysReachedGoal,
                'success_rate' => $successRate,
                'average_daily_ml' => $averageDailyConsumption,
                'daily_data' => $dailyData,
            ],
        ];
    }

    public function getHistory(int $userId, ?string $startDate = null, ?string $endDate = null, int $perPage = 10): array
    {
        $query = UserWaterProgressHistory::where('user_id', $userId)
            ->orderBy('timestamp', 'desc');

        if ($startDate) {
            $query->where('date', '>=', Carbon::parse($startDate));
        }

        if ($endDate) {
            $query->where('date', '<=', Carbon::parse($endDate));
        }

        $history = $query->paginate($perPage);

        return [
            'status' => HttpStatusCodes::OK,
            'data' => $history,
        ];
    }

    public function saveContainer(int $userId, WaterContainerDTO $containerData): array
    {
        $container = UserWaterContainer::updateOrCreate(
            [
                'id' => $containerData->id ?? null,
                'user_id' => $userId
            ],
            [
                'name' => $containerData->name,
                'volume_ml' => $containerData->volume_ml,
                'icon' => $containerData->icon ?? 'glass',
                'color' => $containerData->color ?? '#3498db',
                'is_default' => $containerData->is_default ?? false,
            ]
        );

        // Если этот контейнер устанавливается по умолчанию, сбрасываем флаг для всех остальных
        if ($containerData->is_default) {
            UserWaterContainer::where('user_id', $userId)
                ->where('id', '!=', $container->id)
                ->update(['is_default' => false]);
        }

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => isset($containerData->id) ? 'Контейнер обновлен!' : 'Контейнер создан!',
                'container' => $container,
            ],
        ];
    }

    public function getContainers(int $userId): array
    {
        $containers = UserWaterContainer::where('user_id', $userId)
            ->orderBy('is_default', 'desc')
            ->orderBy('name')
            ->get();

        return [
            'status' => HttpStatusCodes::OK,
            'data' => $containers,
        ];
    }

    public function deleteContainer(int $userId, int $containerId): array
    {
        $container = UserWaterContainer::where('user_id', $userId)
            ->where('id', $containerId)
            ->first();

        if (!$container) {
            return [
                'status' => HttpStatusCodes::NOT_FOUND,
                'data' => [
                    'message' => 'Контейнер не найден.',
                ],
            ];
        }

        $container->delete();

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => 'Контейнер удален!',
            ],
        ];
    }

    public function setReminder(int $userId, WaterReminderDTO $reminderData): array
    {
        $reminder = UserWaterReminder::updateOrCreate(
            [
                'id' => $reminderData->id ?? null,
                'user_id' => $userId
            ],
            [
                'start_time' => $reminderData->start_time,
                'end_time' => $reminderData->end_time,
                'interval_minutes' => $reminderData->interval_minutes,
                'days_of_week' => json_encode($reminderData->days_of_week ?? [1, 2, 3, 4, 5, 6, 7]),
                'is_enabled' => $reminderData->is_enabled ?? true,
                'message' => $reminderData->message ?? 'Пора выпить стакан воды!',
            ]
        );

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => isset($reminderData->id) ? 'Напоминание обновлено!' : 'Напоминание создано!',
                'reminder' => $reminder,
            ],
        ];
    }

    public function getReminders(int $userId): array
    {
        $reminders = UserWaterReminder::where('user_id', $userId)
            ->orderBy('start_time')
            ->get()
            ->map(function ($reminder) {
                $reminder->days_of_week = json_decode($reminder->days_of_week);
                return $reminder;
            });

        return [
            'status' => HttpStatusCodes::OK,
            'data' => $reminders,
        ];
    }

    public function deleteReminder(int $userId, int $reminderId): array
    {
        $reminder = UserWaterReminder::where('user_id', $userId)
            ->where('id', $reminderId)
            ->first();

        if (!$reminder) {
            return [
                'status' => HttpStatusCodes::NOT_FOUND,
                'data' => [
                    'message' => 'Напоминание не найдено.',
                ],
            ];
        }

        $reminder->delete();

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => 'Напоминание удалено!',
            ],
        ];
    }

    public function toggleReminder(int $userId, int $reminderId, bool $isEnabled): array
    {
        $reminder = UserWaterReminder::where('user_id', $userId)
            ->where('id', $reminderId)
            ->first();

        if (!$reminder) {
            return [
                'status' => HttpStatusCodes::NOT_FOUND,
                'data' => [
                    'message' => 'Напоминание не найдено.',
                ],
            ];
        }

        $reminder->update(['is_enabled' => $isEnabled]);

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'message' => $isEnabled ? 'Напоминание включено!' : 'Напоминание отключено!',
                'reminder' => $reminder,
            ],
        ];
    }

    private function checkAchievements(int $userId, UserWaterProgress $progress): array
    {
        $achievements = [];

        if ($progress->glasses_today == 1) {
            $achievements[] = [
                'id' => 'first_glass',
                'name' => 'Первый шаг',
                'description' => 'Вы выпили первый стакан воды сегодня!',
                'icon' => '💧',
            ];
        }

        if ($progress->consumed_ml >= ($progress->daily_goal_ml / 2) &&
            $progress->consumed_ml - $progress->glass_volume_ml < ($progress->daily_goal_ml / 2)) {
            $achievements[] = [
                'id' => 'half_daily_goal',
                'name' => 'На полпути',
                'description' => 'Вы достигли половины дневной нормы!',
                'icon' => '🌊',
            ];
        }

        if ($progress->consumed_ml >= $progress->daily_goal_ml &&
            $progress->consumed_ml - $progress->glass_volume_ml < $progress->daily_goal_ml) {
            $achievements[] = [
                'id' => 'daily_goal_complete',
                'name' => 'Цель достигнута',
                'description' => 'Вы выполнили дневную норму потребления воды!',
                'icon' => '🏆',
            ];
        }

        $streak = $this->getUserStreak($userId);
        if ($streak == 3 || $streak == 7 || $streak == 14 || $streak == 30 || $streak == 90 || $streak == 180 || $streak == 365) {
            $achievements[] = [
                'id' => "streak_{$streak}",
                'name' => "Серия {$streak} дней",
                'description' => "Вы пьете воду {$streak} дней подряд!",
                'icon' => '🔥',
            ];
        }

        return $achievements;
    }

    private function getUserStreak(int $userId): int
    {
        $streak = 0;
        $currentDate = Carbon::today();

        while (true) {
            $progress = UserWaterProgress::where('user_id', $userId)
                ->where('date', $currentDate->toDateString())
                ->first();

            if (!$progress || $progress->consumed_ml < ($progress->daily_goal_ml * 0.5)) {
                break;
            }

            $streak++;
            $currentDate->subDay();
        }

        return $streak;
    }

    private function getBestStreak(int $userId): int
    {
        $progresses = UserWaterProgress::where('user_id', $userId)
            ->orderBy('date', 'desc')
            ->get();

        if ($progresses->isEmpty()) {
            return 0;
        }

        $bestStreak = 0;
        $currentStreak = 0;
        $lastDate = null;

        foreach ($progresses as $progress) {
            $currentDate = Carbon::parse($progress->date);

            $isGoalAchieved = $progress->consumed_ml >= ($progress->daily_goal_ml * 0.5);

            if ($lastDate && $currentDate->diffInDays($lastDate) == 1 && $isGoalAchieved) {
                $currentStreak++;
            } else {
                $currentStreak = $isGoalAchieved ? 1 : 0;
            }

            $bestStreak = max($bestStreak, $currentStreak);
            $lastDate = $currentDate;
        }

        return $bestStreak;
    }

    private function getNextReminder(int $userId): ?array
    {
        $now = Carbon::now();
        $currentDayOfWeek = $now->dayOfWeek;
        $currentTime = $now->format('H:i:s');

        $reminder = UserWaterReminder::where('user_id', $userId)
            ->where('is_enabled', true)
            ->where('start_time', '<=', $currentTime)
            ->where('end_time', '>=', $currentTime)
            ->whereRaw("JSON_CONTAINS(days_of_week, ?)", [json_encode($currentDayOfWeek)])
            ->first();

        if (!$reminder) {
            return null;
        }

        $lastAddition = UserWaterProgressHistory::where('user_id', $userId)
            ->where('date', Carbon::today())
            ->where('action', 'add')
            ->latest('timestamp')
            ->first();

        $lastAddedAt = $lastAddition ? Carbon::parse($lastAddition->timestamp) : Carbon::today()->startOfDay();

        $nextReminderAt = $lastAddedAt->addMinutes($reminder->interval_minutes);

        if ($nextReminderAt->format('H:i:s') > $reminder->end_time || $nextReminderAt < Carbon::now()) {
            return null;
        }

        return [
            'reminder_id' => $reminder->id,
            'message' => $reminder->message,
            'next_at' => $nextReminderAt->toDateTimeString(),
        ];
    }

    public function getConsumptionInsights(int $userId): array
    {
        $startDate = Carbon::now()->subDays(30);
        $endDate = Carbon::now();

        $histories = UserWaterProgressHistory::where('user_id', $userId)
            ->where('action', 'add')
            ->whereBetween('date', [$startDate, $endDate])
            ->get();

        if ($histories->isEmpty()) {
            return [
                'status' => HttpStatusCodes::OK,
                'data' => [
                    'message' => 'Недостаточно данных для анализа.',
                    'insights' => [],
                ],
            ];
        }

        $hourlyData = $histories->groupBy(function ($item) {
            return Carbon::parse($item->timestamp)->format('H');
        })->map(function ($group) {
            return [
                'count' => $group->count(),
                'volume_ml' => $group->sum('volume_ml'),
            ];
        });

        $maxHour = $hourlyData->sortByDesc('volume_ml')->keys()->first();
        $minHour = $hourlyData->sortBy('volume_ml')->filter(function ($value) {
            return $value['count'] > 0;
        })->keys()->first();

        $insights = [];

        $morningConsumption = 0;
        for ($hour = 6; $hour < 12; $hour++) {
            $hourKey = str_pad($hour, 2, '0', STR_PAD_LEFT);
            $morningConsumption += $hourlyData[$hourKey]['volume_ml'] ?? 0;
        }

        $totalConsumption = $hourlyData->sum('volume_ml');
        $morningPercentage = $totalConsumption > 0 ? ($morningConsumption / $totalConsumption) * 100 : 0;

        if ($morningPercentage < 30) {
            $insights[] = [
                'type' => 'morning_hydration',
                'message' => 'Вы пьете мало воды утром. Попробуйте выпивать стакан воды сразу после пробуждения.',
                'priority' => 'high',
            ];
        }

        $eveningConsumption = 0;
        for ($hour = 18; $hour < 24; $hour++) {
            $hourKey = str_pad($hour, 2, '0', STR_PAD_LEFT);
            $eveningConsumption += $hourlyData[$hourKey]['volume_ml'] ?? 0;
        }

        $eveningPercentage = $totalConsumption > 0 ? ($eveningConsumption / $totalConsumption) * 100 : 0;

        if ($eveningPercentage > 40) {
            $insights[] = [
                'type' => 'evening_hydration',
                'message' => 'Вы пьете много воды вечером. Это может привести к нарушению сна. Старайтесь пить больше воды днем.',
                'priority' => 'medium',
            ];
        }

        $dayStats = $histories->groupBy('date')->map(function ($group) {
            return $group->count();
        });

        $averageDrinks = $dayStats->avg();
        $stdDeviation = sqrt($dayStats->map(function ($count) use ($averageDrinks) {
                return pow($count - $averageDrinks, 2);
            })->sum() / $dayStats->count());

        if ($stdDeviation > 3 && $averageDrinks > 0) {
            $insights[] = [
                'type' => 'consistency',
                'message' => 'Ваше потребление воды сильно варьируется день ото дня. Попробуйте пить воду более регулярно.',
                'priority' => 'medium',
            ];
        }

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'hourly_patterns' => $hourlyData,
                'peak_hour' => $maxHour,
                'insights' => $insights,
            ],
        ];
    }

    public function getComparison(int $userId): array
    {
        $userAverage = UserWaterProgress::where('user_id', $userId)
            ->where('date', '>=', Carbon::now()->subDays(30))
            ->avg('consumed_ml');

        if (!$userAverage) {
            return [
                'status' => HttpStatusCodes::OK,
                'data' => [
                    'message' => 'Недостаточно данных для сравнения.',
                ],
            ];
        }

        $globalAverage = DB::table('user_water_progress')
            ->where('date', '>=', Carbon::now()->subDays(30))
            ->avg('consumed_ml');

        $ageGroupAverage = null;

        $allAverages = DB::table('user_water_progress')
            ->where('date', '>=', Carbon::now()->subDays(30))
            ->groupBy('user_id')
            ->select(DB::raw('user_id, AVG(consumed_ml) as average'))
            ->get()
            ->pluck('average')
            ->sort()
            ->values();

        $userRank = $allAverages->search(function ($item) use ($userAverage) {
            return $item >= $userAverage;
        });

        $percentile = $allAverages->count() > 0 ? round(($userRank / $allAverages->count()) * 100) : null;

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'user_average_ml' => round($userAverage),
                'global_average_ml' => round($globalAverage),
                'percentile' => $percentile,
                'above_average' => $userAverage > $globalAverage,
            ],
        ];
    }

    public function getEcoReport(int $userId): array
    {
        $totalConsumed = UserWaterProgress::where('user_id', $userId)->sum('consumed_ml');

        $bottlesSaved = floor($totalConsumed / 500);

        $plasticSaved = $bottlesSaved * 15;

        $co2Saved = ($plasticSaved / 1000) * 6000;

        $waterSaved = $bottlesSaved * 3;

        return [
            'status' => HttpStatusCodes::OK,
            'data' => [
                'bottles_saved' => $bottlesSaved,
                'plastic_saved_g' => $plasticSaved,
                'co2_saved_g' => $co2Saved,
                'water_saved_l' => $waterSaved,
                'trees_equivalent' => round($co2Saved / 20000, 2),
            ],
        ];
    }
}
