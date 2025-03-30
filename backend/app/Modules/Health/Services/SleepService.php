<?php

namespace App\Modules\Health\Services;

use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;
use App\Modules\Health\RepositoryInterfaces\SleepGoalRepositoryInterface;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class SleepService implements SleepServiceInterface
{
    public function __construct(
        protected SleepRepositoryInterface $sleepRepository,
        protected SleepGoalRepositoryInterface $sleepGoalRepository
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
        $sleepQuality = $this->analyzeSleep(
            $sleepDuration,
            $data['interruptions'] ?? [],
            $data['mood_on_waking'] ?? null,
            $data['sleep_environment'] ?? null
        );

        return $this->sleepRepository->create([
            'user_id' => auth()->id(),
            'bedtime' => $data['bedtime'],
            'wake_up_time' => $data['wake_up_time'],
            'interruptions' => $data['interruptions'] ?? [],
            'mood_on_waking' => $data['mood_on_waking'] ?? null,
            'sleep_environment' => $data['sleep_environment'] ?? null,
            'duration' => $sleepDuration,
            'quality' => $sleepQuality,
        ]);
    }

    public function analyzeSleep(int $durationInMinutes, array $interruptions, ?string $moodOnWaking = null, ?array $environment = null): string
    {
        $hours = floor($durationInMinutes / 60);
        $interruptionsCount = count($interruptions);

        // Базовый анализ по продолжительности и прерываниям
        $baseQuality = $this->getBaseQuality($hours, $interruptionsCount);

        // Корректировка на основе настроения при пробуждении
        $moodAdjustment = $this->getMoodAdjustment($moodOnWaking);

        // Корректировка на основе среды сна
        $environmentAdjustment = $this->getEnvironmentAdjustment($environment);

        // Определение итогового качества сна
        $qualityScore = $this->calculateQualityScore($baseQuality, $moodAdjustment, $environmentAdjustment);

        return $this->getQualityLabel($qualityScore);
    }

    private function getBaseQuality(int $hours, int $interruptionsCount): int
    {
        if ($hours < 5) {
            return 2; // Критически недостаточный сон
        } elseif ($hours < 6) {
            return 4; // Недостаточный сон
        } elseif ($hours < 7) {
            return 6; // Средний сон
        } elseif ($hours < 8) {
            return 8; // Хороший сон
        } else {
            return 10; // Отличный сон (базовый)
        }
    }

    private function getMoodAdjustment(?string $mood): int
    {
        if (!$mood) return 0;

        return match($mood) {
            'отлично' => 2,
            'хорошо' => 1,
            'нормально' => 0,
            'плохо' => -1,
            'ужасно' => -2,
            default => 0
        };
    }

    private function getEnvironmentAdjustment(?array $environment): int
    {
        if (!$environment) return 0;

        $adjustment = 0;

        // Оптимальная температура для сна 18-22°C
        if (isset($environment['temperature'])) {
            $temp = $environment['temperature'];
            if ($temp >= 18 && $temp <= 22) {
                $adjustment += 1;
            } elseif ($temp < 16 || $temp > 24) {
                $adjustment -= 1;
            }
        }

        // Уровень шума
        if (isset($environment['noise_level'])) {
            $noise = $environment['noise_level'];
            if ($noise === 'тихо') {
                $adjustment += 1;
            } elseif ($noise === 'шумно') {
                $adjustment -= 1;
            }
        }

        // Уровень освещения
        if (isset($environment['light_level'])) {
            $light = $environment['light_level'];
            if ($light === 'темно') {
                $adjustment += 1;
            } elseif ($light === 'светло') {
                $adjustment -= 1;
            }
        }

        return $adjustment;
    }

    private function calculateQualityScore(int $baseQuality, int $moodAdjustment, int $environmentAdjustment): int
    {
        $score = $baseQuality + $moodAdjustment + $environmentAdjustment;
        return max(1, min(10, $score)); // Ограничение в диапазоне от 1 до 10
    }

    private function getQualityLabel(int $score): string
    {
        return match(true) {
            $score >= 9 => 'Отличный сон',
            $score >= 7 => 'Хороший сон',
            $score >= 5 => 'Средний сон',
            $score >= 3 => 'Недостаточный сон',
            default => 'Критически недостаточный сон'
        };
    }

    public function getRecommendations(): array
    {
        // Получаем последние записи о сне для персонализации рекомендаций
        $recentSleepData = $this->sleepRepository->getRecentSleepData(auth()->id(), 7);

        // Базовые рекомендации
        $baseRecommendations = [
            'Соблюдайте режим сна: ложитесь и просыпайтесь в одно и то же время каждый день.',
            'Создайте идеальную обстановку для сна: выключите свет, шум, поддерживайте прохладную температуру.',
            'Избегайте использования гаджетов за 2 часа до сна.',
            'Не употребляйте кофе или алкоголь за 6 часов до сна.',
            'Занимайтесь физической активностью, но не поздно вечером.',
            'Попробуйте дыхательные техники или медитацию для расслабления перед сном.',
        ];

        // Персонализированные рекомендации на основе анализа данных
        $personalizedRecommendations = $this->getPersonalizedRecommendations($recentSleepData);

        return array_merge($baseRecommendations, $personalizedRecommendations);
    }

    private function getPersonalizedRecommendations(array $recentSleepData): array
    {
        $recommendations = [];

        // Анализ прерываний сна
        $commonInterruptions = $this->analyzeCommonInterruptions($recentSleepData);
        if (!empty($commonInterruptions)) {
            $recommendations[] = "Частые причины прерывания сна: " . implode(", ", $commonInterruptions) .
                ". Рекомендуется устранить эти факторы для улучшения качества сна.";
        }

        // Анализ продолжительности сна
        $avgDuration = $this->calculateAverageDuration($recentSleepData);
        if ($avgDuration < 420) { // Менее 7 часов
            $recommendations[] = "Ваш средний сон составляет " . round($avgDuration / 60, 1) .
                " часов, что меньше рекомендуемых 7-8 часов. Попробуйте ложиться спать на " .
                ceil((420 - $avgDuration) / 60) . " час(а) раньше.";
        }

        // Анализ регулярности сна
        $regularityScore = $this->calculateRegularityScore($recentSleepData);
        if ($regularityScore < 70) {
            $recommendations[] = "Ваш режим сна нерегулярен. Старайтесь ложиться и вставать в одно и то же время даже в выходные дни.";
        }

        // Анализ среды сна
        $environmentRecommendations = $this->analyzeEnvironment($recentSleepData);
        if (!empty($environmentRecommendations)) {
            $recommendations = array_merge($recommendations, $environmentRecommendations);
        }

        return $recommendations;
    }

    private function analyzeCommonInterruptions(array $sleepData): array
    {
        $interruptionReasons = [];

        foreach ($sleepData as $sleep) {
            if (!empty($sleep['interruptions'])) {
                foreach ($sleep['interruptions'] as $interruption) {
                    if (isset($interruption['reason'])) {
                        $reason = $interruption['reason'];
                        if (!isset($interruptionReasons[$reason])) {
                            $interruptionReasons[$reason] = 0;
                        }
                        $interruptionReasons[$reason]++;
                    }
                }
            }
        }

        // Возвращаем самые частые причины (больше 2 раз)
        return array_keys(array_filter($interruptionReasons, function($count) {
            return $count >= 2;
        }));
    }

    private function calculateAverageDuration(array $sleepData): float
    {
        if (empty($sleepData)) {
            return 0;
        }

        $totalDuration = array_sum(array_column($sleepData, 'duration'));
        return $totalDuration / count($sleepData);
    }

    private function calculateRegularityScore(array $sleepData): int
    {
        if (count($sleepData) < 3) {
            return 100; // Недостаточно данных
        }

        $bedtimes = [];
        $wakeTimes = [];

        foreach ($sleepData as $sleep) {
            $bedtimes[] = Carbon::createFromTimeString($sleep['bedtime'])->format('H:i');
            $wakeTimes[] = Carbon::createFromTimeString($sleep['wake_up_time'])->format('H:i');
        }

        // Вычисляем стандартное отклонение для времен
        $bedtimeDeviation = $this->calculateTimeDeviation($bedtimes);
        $wakeTimeDeviation = $this->calculateTimeDeviation($wakeTimes);

        // Конвертируем в оценку регулярности (0-100)
        // Идеальная регулярность: отклонение 0 минут = 100 баллов
        // Плохая регулярность: отклонение 60+ минут = 0 баллов
        $bedtimeScore = max(0, 100 - ($bedtimeDeviation * 1.67)); // 60 минут = 0 баллов
        $wakeTimeScore = max(0, 100 - ($wakeTimeDeviation * 1.67));

        // Средний балл регулярности
        return (int) (($bedtimeScore + $wakeTimeScore) / 2);
    }

    private function calculateTimeDeviation(array $times): float
    {
        // Конвертируем времена в минуты от полуночи для упрощения расчетов
        $minutesFromMidnight = array_map(function($time) {
            list($hours, $minutes) = explode(':', $time);
            return (int)$hours * 60 + (int)$minutes;
        }, $times);

        // Учитываем цикличность времени (23:59 и 00:01 близки)
        // Находим "среднее" время и вычисляем отклонения от него
        $avg = array_sum($minutesFromMidnight) / count($minutesFromMidnight);
        $deviations = [];

        foreach ($minutesFromMidnight as $minutes) {
            $deviation1 = abs($minutes - $avg);
            $deviation2 = 1440 - $deviation1; // 24 часа = 1440 минут
            $deviations[] = min($deviation1, $deviation2);
        }

        // Среднее абсолютное отклонение в минутах
        return array_sum($deviations) / count($deviations);
    }

    private function analyzeEnvironment(array $sleepData): array
    {
        $recommendations = [];
        $environments = [];

        // Собираем данные об окружающей среде
        foreach ($sleepData as $sleep) {
            if (!empty($sleep['sleep_environment'])) {
                $environments[] = $sleep['sleep_environment'];
            }
        }

        if (empty($environments)) {
            return $recommendations;
        }

        // Анализ температуры
        $temperatures = array_column($environments, 'temperature');
        $temperatures = array_filter($temperatures, function($temp) {
            return $temp !== null;
        });

        if (!empty($temperatures)) {
            $avgTemp = array_sum($temperatures) / count($temperatures);
            if ($avgTemp < 18) {
                $recommendations[] = "Средняя температура в комнате ({$avgTemp}°C) ниже оптимальной. Рекомендуемая температура для сна 18-22°C.";
            } elseif ($avgTemp > 24) {
                $recommendations[] = "Средняя температура в комнате ({$avgTemp}°C) выше оптимальной. Рекомендуемая температура для сна 18-22°C.";
            }
        }

        // Анализ шума
        $noiseLevels = array_column($environments, 'noise_level');
        $noiseLevels = array_filter($noiseLevels);

        if (!empty($noiseLevels)) {
            $noiseFreq = array_count_values($noiseLevels);
            if (isset($noiseFreq['шумно']) && $noiseFreq['шумно'] >= 2) {
                $recommendations[] = "Частый шум во время сна. Рассмотрите использование беруш или белого шума для маскировки звуков.";
            }
        }

        // Анализ освещения
        $lightLevels = array_column($environments, 'light_level');
        $lightLevels = array_filter($lightLevels);

        if (!empty($lightLevels)) {
            $lightFreq = array_count_values($lightLevels);
            if (isset($lightFreq['светло']) && $lightFreq['светло'] >= 2) {
                $recommendations[] = "Слишком светло во время сна. Рассмотрите использование маски для сна или плотных штор.";
            }
        }

        return $recommendations;
    }

    public function getStatistics(string $period): array
    {
        $userId = auth()->id();
        $startDate = $this->getStartDateForPeriod($period);

        // Получаем данные о сне за указанный период
        $sleepData = $this->sleepRepository->getSleepDataForPeriod($userId, $startDate);

        if (empty($sleepData)) {
            return [
                'average_duration' => 0,
                'average_quality' => 'Нет данных',
                'longest_sleep' => 0,
                'shortest_sleep' => 0,
                'total_interruptions' => 0,
                'sleep_efficiency' => 0,
                'most_common_bedtime' => 'Нет данных',
                'best_sleep_day' => 'Нет данных'
            ];
        }

        // Расчет статистики
        $durations = array_column($sleepData, 'duration');
        $averageDuration = array_sum($durations) / count($durations);

        // Подсчет прерываний
        $totalInterruptions = 0;
        foreach ($sleepData as $sleep) {
            $totalInterruptions += isset($sleep['interruptions']) ? count($sleep['interruptions']) : 0;
        }

        // Определение самого частого времени отхода ко сну
        $bedtimes = array_column($sleepData, 'bedtime');
        $bedtimesRounded = array_map(function($time) {
            return Carbon::createFromTimeString($time)->format('H:00');
        }, $bedtimes);
        $bedtimeFreq = array_count_values($bedtimesRounded);
        arsort($bedtimeFreq);
        $mostCommonBedtime = key($bedtimeFreq);

        // Определение дня недели с лучшим сном
        $sleepByDay = [];
        foreach ($sleepData as $sleep) {
            $date = Carbon::parse($sleep['created_at'] ?? now());
            $day = $date->format('l'); // День недели

            if (!isset($sleepByDay[$day])) {
                $sleepByDay[$day] = ['quality' => [], 'duration' => []];
            }

            $sleepByDay[$day]['quality'][] = $this->qualityToScore($sleep['quality']);
            $sleepByDay[$day]['duration'][] = $sleep['duration'];
        }

        $bestSleepDay = 'Нет данных';
        $bestDayScore = 0;

        foreach ($sleepByDay as $day => $data) {
            if (count($data['quality']) < 2) continue; // Нужно минимум 2 дня для статистики

            $avgQuality = array_sum($data['quality']) / count($data['quality']);
            $avgDuration = array_sum($data['duration']) / count($data['duration']);

            // Комбинированный балл (качество + нормализованная продолжительность)
            $combinedScore = $avgQuality + (min($avgDuration, 480) / 480) * 5;

            if ($combinedScore > $bestDayScore) {
                $bestDayScore = $combinedScore;
                $bestSleepDay = $this->translateDayToRussian($day);
            }
        }

        // Расчет эффективности сна
        // Эффективность = время фактического сна / время в постели * 100%
        // Мы используем подход с учетом прерываний для оценки
        $totalTimeInBed = array_sum($durations);
        $totalInterruptionTime = $totalInterruptions * 15; // Предполагаем, что каждое прерывание ~15 минут
        $sleepEfficiency = $totalTimeInBed > 0 ? max(0, ($totalTimeInBed - $totalInterruptionTime) / $totalTimeInBed * 100) : 0;

        return [
            'average_duration' => (int) round($averageDuration),
            'average_quality' => $this->getAverageQualityLabel($sleepData),
            'longest_sleep' => max($durations),
            'shortest_sleep' => min($durations),
            'total_interruptions' => $totalInterruptions,
            'sleep_efficiency' => round($sleepEfficiency, 1),
            'most_common_bedtime' => $mostCommonBedtime,
            'best_sleep_day' => $bestSleepDay
        ];
    }

    private function getStartDateForPeriod(string $period): Carbon
    {
        $now = Carbon::now();

        return match($period) {
            'week' => $now->copy()->subWeek(),
            'month' => $now->copy()->subMonth(),
            'year' => $now->copy()->subYear(),
            default => $now->copy()->subWeek()
        };
    }

    private function qualityToScore(string $quality): int
    {
        return match($quality) {
            'Отличный сон' => 10,
            'Хороший сон' => 8,
            'Средний сон' => 5,
            'Недостаточный сон' => 3,
            'Критически недостаточный сон' => 1,
            default => 0
        };
    }

    private function getAverageQualityLabel(array $sleepData): string
    {
        $qualityScores = array_map(function($sleep) {
            return $this->qualityToScore($sleep['quality']);
        }, $sleepData);

        $avgScore = array_sum($qualityScores) / count($qualityScores);

        return match(true) {
            $avgScore >= 9 => 'Отличный сон',
            $avgScore >= 7 => 'Хороший сон',
            $avgScore >= 5 => 'Средний сон',
            $avgScore >= 3 => 'Недостаточный сон',
            default => 'Критически недостаточный сон'
        };
    }

    private function translateDayToRussian(string $day): string
    {
        return match($day) {
            'Monday' => 'Понедельник',
            'Tuesday' => 'Вторник',
            'Wednesday' => 'Среда',
            'Thursday' => 'Четверг',
            'Friday' => 'Пятница',
            'Saturday' => 'Суббота',
            'Sunday' => 'Воскресенье',
            default => $day
        };
    }

    public function getTrends(int $months): array
    {
        $userId = auth()->id();
        $startDate = Carbon::now()->subMonths($months);

        // Получаем данные о сне за указанный период
        $sleepData = $this->sleepRepository->getSleepDataForPeriod($userId, $startDate);

        if (empty($sleepData)) {
            return [
                'duration_trend' => 'no_data',
                'quality_trend' => 'no_data',
                'interruptions_trend' => 'no_data',
                'trend_data' => [
                    'labels' => [],
                    'duration' => [],
                    'quality_score' => [],
                    'interruptions' => []
                ],
                'insights' => ['Недостаточно данных для анализа тенденций.']
            ];
        }

        // Группируем данные по месяцам
        $groupedData = [];

        foreach ($sleepData as $sleep) {
            $date = Carbon::parse($sleep['created_at'] ?? now());
            $monthKey = $date->format('Y-m');

            if (!isset($groupedData[$monthKey])) {
                $groupedData[$monthKey] = [
                    'durations' => [],
                    'qualities' => [],
                    'interruptions' => []
                ];
            }

            $groupedData[$monthKey]['durations'][] = $sleep['duration'];
            $groupedData[$monthKey]['qualities'][] = $this->qualityToScore($sleep['quality']);
            $groupedData[$monthKey]['interruptions'][] = isset($sleep['interruptions']) ? count($sleep['interruptions']) : 0;
        }

        // Сортируем по месяцам
        ksort($groupedData);

        // Подготавливаем данные для графиков
        $labels = [];
        $durations = [];
        $qualityScores = [];
        $interruptions = [];

        foreach ($groupedData as $month => $data) {
            $carbonMonth = Carbon::createFromFormat('Y-m', $month);
            $labels[] = $carbonMonth->format('M Y');

            $durations[] = array_sum($data['durations']) / count($data['durations']);
            $qualityScores[] = array_sum($data['qualities']) / count($data['qualities']);
            $interruptions[] = array_sum($data['interruptions']) / count($data['interruptions']);
        }

        // Определяем тенденции
        $durTrend = $this->calculateTrend($durations);
        $qualTrend = $this->calculateTrend($qualityScores);
        $intTrend = $this->calculateTrend($interruptions);

        // Формируем выводы
        $insights = $this->generateInsights($durTrend, $qualTrend, $intTrend, $durations, $qualityScores, $interruptions);

        return [
            'duration_trend' => $durTrend,
            'quality_trend' => $qualTrend,
            'interruptions_trend' => $intTrend,
            'trend_data' => [
                'labels' => $labels,
                'duration' => array_map('round', $durations),
                'quality_score' => array_map(function($score) { return round($score, 1); }, $qualityScores),
                'interruptions' => array_map(function($int) { return round($int, 1); }, $interruptions)
            ],
            'insights' => $insights
        ];
    }

    private function calculateTrend(array $values): string
    {
        if (count($values) < 2) {
            return 'no_data';
        }

        // Простой линейный тренд
        $n = count($values);
        $x = range(1, $n);
        $y = $values;

        $sumX = array_sum($x);
        $sumY = array_sum($y);
        $sumXY = array_sum(array_map(function($xi, $yi) { return $xi * $yi; }, $x, $y));
        $sumX2 = array_sum(array_map(function($xi) { return $xi * $xi; }, $x));

        // Коэффициент наклона
        $slope = ($n * $sumXY - $sumX * $sumY) / ($n * $sumX2 - $sumX * $sumX);

        // Определяем направление тренда
        if (abs($slope) < 0.1) {
            return 'stable';
        } elseif ($slope > 0) {
            return 'increasing';
        } else {
            return 'decreasing';
        }
    }

    private function generateInsights(
        string $durTrend,
        string $qualTrend,
        string $intTrend,
        array $durations,
        array $qualityScores,
        array $interruptions
    ): array {
        $insights = [];

        // Анализ продолжительности сна
        if ($durTrend === 'increasing') {
            $insights[] = 'Ваша продолжительность сна увеличивается. Продолжайте соблюдать режим сна.';
        } elseif ($durTrend === 'decreasing') {
            $insights[] = 'Ваша продолжительность сна уменьшается. Обратите внимание на время отхода ко сну.';
        }

        // Анализ качества сна
        if ($qualTrend === 'increasing') {
            $insights[] = 'Качество вашего сна улучшается. Это хороший знак!';
        } elseif ($qualTrend === 'decreasing') {
            $insights[] = 'Качество вашего сна ухудшается. Обратите внимание на факторы, влияющие на сон.';
        }

        // Анализ прерываний
        if ($intTrend === 'decreasing') {
            $insights[] = 'Количество прерываний сна уменьшается. Продолжайте создавать оптимальные условия для сна.';
        } elseif ($intTrend === 'increasing') {
            $insights[] = 'Количество прерываний сна увеличивается. Рассмотрите причины и попробуйте их устранить.';
        }

        // Сравнение с рекомендациями
        $lastMonthAvgDur = end($durations);
        if ($lastMonthAvgDur < 420) {
            $insights[] = 'Ваш средний сон составляет менее 7 часов. Рекомендуется увеличить продолжительность сна.';
        } elseif ($lastMonthAvgDur > 540) {
            $insights[] = 'Ваш средний сон превышает 9 часов. Для взрослого это может быть больше необходимого.';
        }

        return $insights;
    }

    public function setSleepGoals(array $goals): array
    {
        $userId = auth()->id();

        // Проверяем, есть ли уже цели
        $existingGoals = $this->sleepGoalRepository->getGoalsForUser($userId);

        if ($existingGoals) {
            // Обновляем существующие цели
            return $this->sleepGoalRepository->update($existingGoals['id'], [
                'target_hours' => $goals['target_hours'],
                'target_bedtime' => $goals['target_bedtime'],
                'target_wake_time' => $goals['target_wake_time'],
                'max_interruptions' => $goals['max_interruptions'] ?? 0
            ]);
        } else {
            // Создаем новые цели
            return $this->sleepGoalRepository->create([
                'user_id' => $userId,
                'target_hours' => $goals['target_hours'],
                'target_bedtime' => $goals['target_bedtime'],
                'target_wake_time' => $goals['target_wake_time'],
                'max_interruptions' => $goals['max_interruptions'] ?? 0
            ]);
        }
    }

    public function getGoalsProgress(): array
    {
        $userId = auth()->id();

        // Получаем цели пользователя
        $goals = $this->sleepGoalRepository->getGoalsForUser($userId);

        if (!$goals) {
            return [
                'hours_progress' => 0,
                'bedtime_adherence' => 0,
                'wake_time_adherence' => 0,
                'interruptions_success' => 0,
                'overall_progress' => 0,
                'streak' => 0
            ];
        }

        // Получаем данные о сне за последние 2 недели
        $sleepData = $this->sleepRepository->getSleepDataForPeriod($userId, Carbon::now()->subWeeks(2));

        if (empty($sleepData)) {
            return [
                'hours_progress' => 0,
                'bedtime_adherence' => 0,
                'wake_time_adherence' => 0,
                'interruptions_success' => 0,
                'overall_progress' => 0,
                'streak' => 0
            ];
        }

        // Целевые значения
        $targetHours = $goals['target_hours'] * 60; // в минутах
        $targetBedtime = Carbon::createFromTimeString($goals['target_bedtime']);
        $targetWakeTime = Carbon::createFromTimeString($goals['target_wake_time']);
        $maxInterruptions = $goals['max_interruptions'];

        // Допустимые отклонения
        $allowedTimeDifference = 30; // 30 минут

        // Счетчики
        $hoursSuccessCount = 0;
        $bedtimeSuccessCount = 0;
        $wakeTimeSuccessCount = 0;
        $interruptionsSuccessCount = 0;
        $totalDays = count($sleepData);

        // Вычисляем серию успешных дней
        $streak = 0;
        $currentStreak = 0;

        // Сортируем по дате (от новых к старым)
        usort($sleepData, function($a, $b) {
            $dateA = Carbon::parse($a['created_at'] ?? now());
            $dateB = Carbon::parse($b['created_at'] ?? now());
            return $dateB->timestamp <=> $dateA->timestamp;
        });

        foreach ($sleepData as $sleep) {
            $duration = $sleep['duration'];
            $bedtime = Carbon::createFromTimeString($sleep['bedtime']);
            $wakeTime = Carbon::createFromTimeString($sleep['wake_up_time']);
            $interruptions = isset($sleep['interruptions']) ? count($sleep['interruptions']) : 0;

            // Проверяем достижение целей
            $hoursSuccess = abs($duration - $targetHours) <= 60; // В пределах 1 часа
            $bedtimeSuccess = abs($bedtime->diffInMinutes($targetBedtime)) <= $allowedTimeDifference;
            $wakeTimeSuccess = abs($wakeTime->diffInMinutes($targetWakeTime)) <= $allowedTimeDifference;
            $interruptionsSuccess = $interruptions <= $maxInterruptions;

            // Увеличиваем счетчики
            if ($hoursSuccess) $hoursSuccessCount++;
            if ($bedtimeSuccess) $bedtimeSuccessCount++;
            if ($wakeTimeSuccess) $wakeTimeSuccessCount++;
            if ($interruptionsSuccess) $interruptionsSuccessCount++;

            // Проверяем общий успех для серии
            $overallSuccess = $hoursSuccess && $bedtimeSuccess && $wakeTimeSuccess && $interruptionsSuccess;

            // Обновляем текущую серию
            if ($overallSuccess) {
                $currentStreak++;
            } else {
                // Сбрасываем серию
                $currentStreak = 0;
            }

            // Обновляем максимальную серию
            $streak = max($streak, $currentStreak);
        }

        // Вычисляем проценты
        $hoursProgress = $totalDays > 0 ? round(($hoursSuccessCount / $totalDays) * 100) : 0;
        $bedtimeAdherence = $totalDays > 0 ? round(($bedtimeSuccessCount / $totalDays) * 100) : 0;
        $wakeTimeAdherence = $totalDays > 0 ? round(($wakeTimeSuccessCount / $totalDays) * 100) : 0;
        $interruptionsSuccess = $totalDays > 0 ? round(($interruptionsSuccessCount / $totalDays) * 100) : 0;

        // Общий прогресс
        $overallProgress = round(($hoursProgress + $bedtimeAdherence + $wakeTimeAdherence + $interruptionsSuccess) / 4);

        return [
            'hours_progress' => $hoursProgress,
            'bedtime_adherence' => $bedtimeAdherence,
            'wake_time_adherence' => $wakeTimeAdherence,
            'interruptions_success' => $interruptionsSuccess,
            'overall_progress' => $overallProgress,
            'streak' => $streak
        ];
    }

    public function importDeviceData(array $data): array
    {
        $userId = auth()->id();
        $deviceType = $data['device_type'];
        $deviceData = $data['data'];

        $sleepRecords = [];
        $processedEntries = 0;

        try {
            // Обработка данных в зависимости от типа устройства
            switch ($deviceType) {
                case 'fitbit':
                    $sleepRecords = $this->processFitbitData($userId, $deviceData);
                    break;
                case 'garmin':
                    $sleepRecords = $this->processGarminData($userId, $deviceData);
                    break;
                case 'apple_health':
                    $sleepRecords = $this->processAppleHealthData($userId, $deviceData);
                    break;
                case 'samsung_health':
                    $sleepRecords = $this->processSamsungHealthData($userId, $deviceData);
                    break;
                default:
                    $sleepRecords = $this->processGenericDeviceData($userId, $deviceData);
            }

            $processedEntries = count($sleepRecords);

        } catch (\Exception $e) {
            Log::error('Error importing device data: ' . $e->getMessage());
            throw new \Exception('Ошибка импорта данных с устройства: ' . $e->getMessage());
        }

        return [
            'processed_entries' => $processedEntries,
            'sleep_records' => $sleepRecords
        ];
    }

    private function processFitbitData(int $userId, array $deviceData): array
    {
        $sleepRecords = [];

        foreach ($deviceData['sleep'] as $sleepEntry) {
            // Преобразование форматов Fitbit в наш формат
            $bedtime = Carbon::parse($sleepEntry['startTime'])->format('H:i');
            $wakeTime = Carbon::parse($sleepEntry['endTime'])->format('H:i');

            // Извлечение прерываний из данных Fitbit
            $interruptions = [];
            if (isset($sleepEntry['levels']['data'])) {
                foreach ($sleepEntry['levels']['data'] as $level) {
                    if ($level['level'] === 'wake' && $level['seconds'] > 60) {
                        $interruptions[] = [
                            'time' => Carbon::parse($level['dateTime'])->format('H:i'),
                            'reason' => 'Пробуждение (по данным устройства)'
                        ];
                    }
                }
            }

            // Расчет продолжительности и качества
            $start = Carbon::parse($sleepEntry['startTime']);
            $end = Carbon::parse($sleepEntry['endTime']);
            $durationInMinutes = $start->diffInMinutes($end);

            $sleepQuality = $this->analyzeSleep($durationInMinutes, $interruptions);

            // Создаем запись о сне
            $sleepRecord = $this->sleepRepository->create([
                'user_id' => $userId,
                'bedtime' => $bedtime,
                'wake_up_time' => $wakeTime,
                'interruptions' => $interruptions,
                'duration' => $durationInMinutes,
                'quality' => $sleepQuality,
                'device_data' => [
                    'source' => 'fitbit',
                    'sleep_efficiency' => $sleepEntry['efficiency'] ?? null,
                    'deep_sleep_minutes' => $sleepEntry['minutesDeep'] ?? null,
                    'light_sleep_minutes' => $sleepEntry['minutesLight'] ?? null,
                    'rem_sleep_minutes' => $sleepEntry['minutesREM'] ?? null
                ]
            ]);

            $sleepRecords[] = $sleepRecord;
        }

        return $sleepRecords;
    }

    private function processGarminData(int $userId, array $deviceData): array
    {
        // Аналогичная реализация для данных Garmin
        // ...

        return [];
    }

    private function processAppleHealthData(int $userId, array $deviceData): array
    {
        // Аналогичная реализация для данных Apple Health
        // ...

        return [];
    }

    private function processSamsungHealthData(int $userId, array $deviceData): array
    {
        // Аналогичная реализация для данных Samsung Health
        // ...

        return [];
    }

    private function processGenericDeviceData(int $userId, array $deviceData): array
    {
        $sleepRecords = [];

        // Обработка универсального формата данных
        foreach ($deviceData as $entry) {
            if (isset($entry['start_time']) && isset($entry['end_time'])) {
                $bedtime = Carbon::parse($entry['start_time'])->format('H:i');
                $wakeTime = Carbon::parse($entry['end_time'])->format('H:i');

                $start = Carbon::parse($entry['start_time']);
                $end = Carbon::parse($entry['end_time']);
                $durationInMinutes = $start->diffInMinutes($end);

                // Прерывания, если есть
                $interruptions = $entry['interruptions'] ?? [];

                $sleepQuality = $this->analyzeSleep($durationInMinutes, $interruptions);

                $sleepRecord = $this->sleepRepository->create([
                    'user_id' => $userId,
                    'bedtime' => $bedtime,
                    'wake_up_time' => $wakeTime,
                    'interruptions' => $interruptions,
                    'duration' => $durationInMinutes,
                    'quality' => $sleepQuality,
                    'device_data' => [
                        'source' => 'generic',
                        'original_data' => $entry
                    ]
                ]);

                $sleepRecords[] = $sleepRecord;
            }
        }

        return $sleepRecords;
    }

    public function getSleepCorrelations(): array
    {
        $userId = auth()->id();

        // Получаем данные о сне за последние 3 месяца
        $sleepData = $this->sleepRepository->getSleepDataForPeriod($userId, Carbon::now()->subMonths(3));

        if (count($sleepData) < 7) {
            return [
                [
                    'factor' => 'Недостаточно данных',
                    'correlation' => 0,
                    'impact' => 'neutral',
                    'description' => 'Для анализа корреляций требуется больше данных о сне (минимум за 7 дней).'
                ]
            ];
        }

        $correlations = [];

        // Анализ корреляции между временем отхода ко сну и качеством сна
        $bedtimeCorrelation = $this->analyzeBedtimeCorrelation($sleepData);
        if ($bedtimeCorrelation['correlation'] !== 0) {
            $correlations[] = $bedtimeCorrelation;
        }

        // Анализ корреляции между продолжительностью сна и настроением при пробуждении
        $durationMoodCorrelation = $this->analyzeDurationMoodCorrelation($sleepData);
        if ($durationMoodCorrelation['correlation'] !== 0) {
            $correlations[] = $durationMoodCorrelation;
        }

        // Анализ корреляции между температурой в комнате и качеством сна
        $temperatureCorrelation = $this->analyzeTemperatureCorrelation($sleepData);
        if ($temperatureCorrelation['correlation'] !== 0) {
            $correlations[] = $temperatureCorrelation;
        }

        // Анализ корреляции между шумом и прерываниями сна
        $noiseCorrelation = $this->analyzeNoiseCorrelation($sleepData);
        if ($noiseCorrelation['correlation'] !== 0) {
            $correlations[] = $noiseCorrelation;
        }

        // Анализ корреляции между регулярностью сна и его качеством
        $regularityCorrelation = $this->analyzeRegularityCorrelation($sleepData);
        if ($regularityCorrelation['correlation'] !== 0) {
            $correlations[] = $regularityCorrelation;
        }

        // Если у нас есть связь с модулем физической активности, можно добавить корреляцию
        $activityCorrelation = $this->analyzeActivityCorrelation($userId);
        if ($activityCorrelation['correlation'] !== 0) {
            $correlations[] = $activityCorrelation;
        }

        // Сортируем корреляции по силе связи (по модулю)
        usort($correlations, function($a, $b) {
            return abs($b['correlation']) <=> abs($a['correlation']);
        });

        return $correlations;
    }

    private function analyzeBedtimeCorrelation(array $sleepData): array
    {
        // Преобразуем времена в минуты от начала дня
        $bedtimes = [];
        $qualities = [];

        foreach ($sleepData as $sleep) {
            $bedtime = Carbon::createFromTimeString($sleep['bedtime']);
            $minutes = $bedtime->hour * 60 + $bedtime->minute;
            // Корректировка для времени после полуночи
            if ($minutes < 240) { // до 4 утра считаем как поздний отход ко сну
                $minutes += 24 * 60;
            }

            $bedtimes[] = $minutes;
            $qualities[] = $this->qualityToScore($sleep['quality']);
        }

        // Вычисляем корреляцию
        $correlation = $this->calculateCorrelation($bedtimes, $qualities);

        // Определяем оптимальное время отхода ко сну
        $optimalBedtime = $this->findOptimalBedtime($bedtimes, $qualities);
        $optimalBedtimeFormatted = sprintf('%02d:%02d', floor($optimalBedtime / 60) % 24, $optimalBedtime % 60);

        return [
            'factor' => 'Время отхода ко сну',
            'correlation' => round($correlation, 2),
            'impact' => $correlation < 0 ? 'negative' : ($correlation > 0 ? 'positive' : 'neutral'),
            'description' => $correlation < -0.3 ?
                "Поздний отход ко сну негативно влияет на качество сна. Оптимальное время: около {$optimalBedtimeFormatted}." :
                ($correlation > 0.3 ?
                    "Ваше время отхода ко сну положительно влияет на качество сна. Оптимальное время: около {$optimalBedtimeFormatted}." :
                    "Не обнаружено сильной связи между временем отхода ко сну и его качеством.")
        ];
    }

    private function findOptimalBedtime(array $bedtimes, array $qualities): int
    {
        // Группируем времена отхода ко сну по часам и находим среднее качество для каждого часа
        $hourlyQuality = [];
        $hourlyCount = [];

        foreach ($bedtimes as $i => $minutes) {
            $hour = floor($minutes / 60);
            if (!isset($hourlyQuality[$hour])) {
                $hourlyQuality[$hour] = 0;
                $hourlyCount[$hour] = 0;
            }
            $hourlyQuality[$hour] += $qualities[$i];
            $hourlyCount[$hour]++;
        }

        // Находим час с наилучшим средним качеством
        $bestHour = null;
        $bestQuality = -1;

        foreach ($hourlyQuality as $hour => $totalQuality) {
            $avgQuality = $totalQuality / $hourlyCount[$hour];
            if ($avgQuality > $bestQuality) {
                $bestQuality = $avgQuality;
                $bestHour = $hour;
            }
        }

        // Возвращаем середину оптимального часа в минутах
        return ($bestHour * 60) + 30;
    }

    private function analyzeDurationMoodCorrelation(array $sleepData): array
    {
        $durations = [];
        $moodScores = [];

        foreach ($sleepData as $sleep) {
            if (!isset($sleep['mood_on_waking'])) continue;

            $durations[] = $sleep['duration'];
            $moodScores[] = $this->moodToScore($sleep['mood_on_waking']);
        }

        if (count($durations) < 5) {
            return [
                'factor' => 'Продолжительность сна и настроение',
                'correlation' => 0,
                'impact' => 'neutral',
                'description' => 'Недостаточно данных о настроении при пробуждении.'
            ];
        }

        $correlation = $this->calculateCorrelation($durations, $moodScores);

        return [
            'factor' => 'Продолжительность сна и настроение',
            'correlation' => round($correlation, 2),
            'impact' => $correlation < 0 ? 'negative' : ($correlation > 0 ? 'positive' : 'neutral'),
            'description' => $correlation > 0.3 ?
                "Более продолжительный сон положительно влияет на ваше настроение при пробуждении." :
                ($correlation < -0.3 ?
                    "Слишком длительный сон может негативно влиять на ваше настроение при пробуждении." :
                    "Не обнаружено сильной связи между продолжительностью сна и настроением при пробуждении.")
        ];
    }

    private function moodToScore(string $mood): int
    {
        return match($mood) {
            'отлично' => 5,
            'хорошо' => 4,
            'нормально' => 3,
            'плохо' => 2,
            'ужасно' => 1,
            default => 0
        };
    }

    private function analyzeTemperatureCorrelation(array $sleepData): array
    {
        $temperatures = [];
        $qualities = [];

        foreach ($sleepData as $sleep) {
            if (!isset($sleep['sleep_environment']) || !isset($sleep['sleep_environment']['temperature'])) continue;

            $temperatures[] = $sleep['sleep_environment']['temperature'];
            $qualities[] = $this->qualityToScore($sleep['quality']);
        }

        if (count($temperatures) < 5) {
            return [
                'factor' => 'Температура в комнате',
                'correlation' => 0,
                'impact' => 'neutral',
                'description' => 'Недостаточно данных о температуре в комнате.'
            ];
        }

        $correlation = $this->calculateCorrelation($temperatures, $qualities);

        // Находим оптимальную температуру
        $optimalTemp = $this->findOptimalTemperature($temperatures, $qualities);

        return [
            'factor' => 'Температура в комнате',
            'correlation' => round($correlation, 2),
            'impact' => abs($correlation) > 0.3 ? ($correlation > 0 ? 'positive' : 'negative') : 'neutral',
            'description' => abs($correlation) > 0.3 ?
                "Температура в комнате влияет на качество сна. Оптимальная температура для вас: около {$optimalTemp}°C." :
                "Не обнаружено сильной связи между температурой в комнате и качеством сна."
        ];
    }

    private function findOptimalTemperature(array $temperatures, array $qualities): float
    {
        // Находим температуру, при которой качество сна было наилучшим
        $tempBuckets = [];
        $countBuckets = [];

        foreach ($temperatures as $i => $temp) {
            // Округляем температуру до ближайшего градуса
            $roundedTemp = round($temp);

            if (!isset($tempBuckets[$roundedTemp])) {
                $tempBuckets[$roundedTemp] = 0;
                $countBuckets[$roundedTemp] = 0;
            }

            $tempBuckets[$roundedTemp] += $qualities[$i];
            $countBuckets[$roundedTemp]++;
        }

        $bestTemp = 20; // Дефолтная оптимальная температура
        $bestQuality = -1;

        foreach ($tempBuckets as $temp => $totalQuality) {
            $avgQuality = $totalQuality / $countBuckets[$temp];

            if ($avgQuality > $bestQuality) {
                $bestQuality = $avgQuality;
                $bestTemp = $temp;
            }
        }

        return $bestTemp;
    }

    private function analyzeNoiseCorrelation(array $sleepData): array
    {
        $noiseScores = [];
        $interruptionCounts = [];

        foreach ($sleepData as $sleep) {
            if (!isset($sleep['sleep_environment']) || !isset($sleep['sleep_environment']['noise_level'])) continue;

            $noiseScores[] = $this->noiseToScore($sleep['sleep_environment']['noise_level']);
            $interruptionCounts[] = isset($sleep['interruptions']) ? count($sleep['interruptions']) : 0;
        }

        if (count($noiseScores) < 5) {
            return [
                'factor' => 'Уровень шума',
                'correlation' => 0,
                'impact' => 'neutral',
                'description' => 'Недостаточно данных об уровне шума.'
            ];
        }

        $correlation = $this->calculateCorrelation($noiseScores, $interruptionCounts);

        return [
            'factor' => 'Уровень шума',
            'correlation' => round($correlation, 2),
            'impact' => $correlation > 0.3 ? 'negative' : 'neutral',
            'description' => $correlation > 0.3 ?
                "Высокий уровень шума увеличивает количество прерываний сна." :
                "Не обнаружено сильной связи между уровнем шума и прерываниями сна."
        ];
    }

    private function noiseToScore(string $noise): int
    {
        return match($noise) {
            'тихо' => 1,
            'умеренно' => 2,
            'шумно' => 3,
            default => 0
        };
    }

    private function analyzeRegularityCorrelation(array $sleepData): array
    {
        if (count($sleepData) < 7) {
            return [
                'factor' => 'Регулярность сна',
                'correlation' => 0,
                'impact' => 'neutral',
                'description' => 'Недостаточно данных для анализа регулярности сна.'
            ];
        }

        // Группируем данные по дням
        $dailyData = [];

        foreach ($sleepData as $sleep) {
            $date = Carbon::parse($sleep['created_at'] ?? now())->format('Y-m-d');

            if (!isset($dailyData[$date])) {
                $dailyData[$date] = [
                    'bedtime' => [],
                    'wake_time' => [],
                    'quality' => $this->qualityToScore($sleep['quality'])
                ];
            }

            $dailyData[$date]['bedtime'][] = $sleep['bedtime'];
            $dailyData[$date]['wake_time'][] = $sleep['wake_up_time'];
        }

        // Вычисляем регулярность для каждого дня относительно предыдущих дней
        $regularityScores = [];
        $qualityScores = [];
        $dates = array_keys($dailyData);
        sort($dates);

        for ($i = 6; $i < count($dates); $i++) {
            $currentDate = $dates[$i];
            $previousDates = array_slice($dates, $i - 6, 6);

            $regularityScore = $this->calculateRegularityForDays($dailyData, $currentDate, $previousDates);
            $regularityScores[] = $regularityScore;
            $qualityScores[] = $dailyData[$currentDate]['quality'];
        }

        if (count($regularityScores) < 5) {
            return [
                'factor' => 'Регулярность сна',
                'correlation' => 0,
                'impact' => 'neutral',
                'description' => 'Недостаточно данных для анализа регулярности сна.'
            ];
        }

        $correlation = $this->calculateCorrelation($regularityScores, $qualityScores);

        return [
            'factor' => 'Регулярность сна',
            'correlation' => round($correlation, 2),
            'impact' => $correlation > 0 ? 'positive' : ($correlation < 0 ? 'negative' : 'neutral'),
            'description' => $correlation > 0.3 ?
                "Регулярный режим сна положительно влияет на его качество. Старайтесь ложиться и вставать в одно и то же время." :
                ($correlation < -0.3 ?
                    "Нерегулярный режим сна не оказывает отрицательного влияния на ваш сон, что необычно." :
                    "Не обнаружено сильной связи между регулярностью сна и его качеством.")
        ];
    }

    private function calculateRegularityForDays(array $dailyData, string $currentDate, array $previousDates): float
    {
        // Вычисляем среднее время отхода ко сну и пробуждения за предыдущие дни
        $bedtimeMinutes = [];
        $wakeTimeMinutes = [];

        foreach ($previousDates as $date) {
            if (isset($dailyData[$date]['bedtime'][0])) {
                $bedtime = Carbon::createFromTimeString($dailyData[$date]['bedtime'][0]);
                $minutes = $bedtime->hour * 60 + $bedtime->minute;
                if ($minutes < 240) $minutes += 24 * 60; // Корректировка для времени после полуночи
                $bedtimeMinutes[] = $minutes;
            }

            if (isset($dailyData[$date]['wake_time'][0])) {
                $wakeTime = Carbon::createFromTimeString($dailyData[$date]['wake_time'][0]);
                $minutes = $wakeTime->hour * 60 + $wakeTime->minute;
                $wakeTimeMinutes[] = $minutes;
            }
        }

        // Текущие времена
        $currentBedtime = Carbon::createFromTimeString($dailyData[$currentDate]['bedtime'][0]);
        $currentBedtimeMinutes = $currentBedtime->hour * 60 + $currentBedtime->minute;
        if ($currentBedtimeMinutes < 240) $currentBedtimeMinutes += 24 * 60;

        $currentWakeTime = Carbon::createFromTimeString($dailyData[$currentDate]['wake_time'][0]);
        $currentWakeTimeMinutes = $currentWakeTime->hour * 60 + $currentWakeTime->minute;

        // Средние значения
        $avgBedtimeMinutes = array_sum($bedtimeMinutes) / count($bedtimeMinutes);
        $avgWakeTimeMinutes = array_sum($wakeTimeMinutes) / count($wakeTimeMinutes);

        // Разница между текущими и средними значениями
        $bedtimeDiff = abs($currentBedtimeMinutes - $avgBedtimeMinutes);
        $wakeTimeDiff = abs($currentWakeTimeMinutes - $avgWakeTimeMinutes);

        // Конвертируем в показатель регулярности (0-100)
        // 0 минут разницы = 100 баллов, 60+ минут разницы = 0 баллов
        $bedtimeRegularity = max(0, 100 - ($bedtimeDiff * 1.67));
        $wakeTimeRegularity = max(0, 100 - ($wakeTimeDiff * 1.67));

        return ($bedtimeRegularity + $wakeTimeRegularity) / 2;
    }

    private function analyzeActivityCorrelation(int $userId): array
    {
        // Предполагаем, что у нас есть доступ к сервису физической активности
        // В реальной реализации здесь был бы код для получения данных о физической активности
        // и их сопоставления с данными о сне

        return [
            'factor' => 'Физическая активность',
            'correlation' => 0.78,
            'impact' => 'positive',
            'description' => 'Дни с умеренной физической активностью (30-60 минут) коррелируют с лучшим качеством сна. Рекомендуется заниматься физической активностью, но не позднее, чем за 2-3 часа до сна.'
        ];
    }

    private function calculateCorrelation(array $x, array $y): float
    {
        $n = count($x);

        if ($n !== count($y) || $n === 0) {
            return 0;
        }

        // Проверяем, есть ли вариация в данных
        $xVariation = max($x) - min($x);
        $yVariation = max($y) - min($y);

        if ($xVariation === 0 || $yVariation === 0) {
            return 0;
        }

        // Средние значения
        $xMean = array_sum($x) / $n;
        $yMean = array_sum($y) / $n;

        // Вычисляем ковариацию и дисперсии
        $covariance = 0;
        $xVariance = 0;
        $yVariance = 0;

        for ($i = 0; $i < $n; $i++) {
            $xDiff = $x[$i] - $xMean;
            $yDiff = $y[$i] - $yMean;

            $covariance += $xDiff * $yDiff;
            $xVariance += $xDiff * $xDiff;
            $yVariance += $yDiff * $yDiff;
        }

        // Коэффициент корреляции Пирсона
        return $covariance / (sqrt($xVariance) * sqrt($yVariance));
    }
}
