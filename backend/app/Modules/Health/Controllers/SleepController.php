<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\Requests\ImportDeviceDataRequest;
use App\Modules\Health\Requests\RecordSleepRequest;
use App\Modules\Health\Requests\SetSleepGoalRequest;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SleepController extends Controller
{
    public function __construct(protected SleepServiceInterface $sleepService
    ) {
    }

    /**
     * @OA\Post(
     *     path="/api/sleep/record",
     *     summary="Запись данных о сне",
     *     tags={"Sleep"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="bedtime", type="string", format="time", example="23:30", description="Время отхода ко сну"),
     *             @OA\Property(property="wake_up_time", type="string", format="time", example="07:00", description="Время пробуждения"),
     *             @OA\Property(property="interruptions", type="array", nullable=true, description="Прерывания сна",
     *                 @OA\Items(
     *                     @OA\Property(property="time", type="string", format="time", example="02:15", description="Время прерывания"),
     *                     @OA\Property(property="reason", type="string", example="Шум", description="Причина прерывания")
     *                 )
     *             ),
     *             @OA\Property(property="mood_on_waking", type="string", enum={"отлично", "хорошо", "нормально", "плохо", "ужасно"}, example="хорошо", description="Настроение при пробуждении"),
     *             @OA\Property(property="sleep_environment", type="object", nullable=true, description="Условия сна",
     *                 @OA\Property(property="temperature", type="number", format="float", example=20.5, description="Температура в комнате (°C)"),
     *                 @OA\Property(property="noise_level", type="string", enum={"тихо", "умеренно", "шумно"}, example="тихо", description="Уровень шума"),
     *                 @OA\Property(property="light_level", type="string", enum={"темно", "полутемно", "светло"}, example="темно", description="Уровень освещения")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные о сне успешно записаны",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Данные о сне успешно записаны."),
     *             @OA\Property(property="sleep_data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="user_id", type="integer", example=1),
     *                 @OA\Property(property="bedtime", type="string", example="23:30"),
     *                 @OA\Property(property="wake_up_time", type="string", example="07:00"),
     *                 @OA\Property(property="interruptions", type="array", nullable=true,
     *                     @OA\Items(
     *                         @OA\Property(property="time", type="string", example="02:15"),
     *                         @OA\Property(property="reason", type="string", example="Шум")
     *                     )
     *                 ),
     *                 @OA\Property(property="mood_on_waking", type="string", example="хорошо"),
     *                 @OA\Property(property="sleep_environment", type="object", nullable=true),
     *                 @OA\Property(property="duration", type="integer", example=450, description="Продолжительность сна в минутах"),
     *                 @OA\Property(property="quality", type="string", example="Хороший сон", description="Качество сна")
     *             )
     *         )
     *     )
     * )
     */
    public function recordSleep(RecordSleepRequest $request): JsonResponse
    {
        $sleepData = $this->sleepService->recordSleep($request->validated());

        return response()->json([
            'message'    => 'Данные о сне успешно записаны.',
            'sleep_data' => $sleepData,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/sleep/recommendations",
     *     summary="Получение рекомендаций по улучшению сна",
     *     tags={"Sleep"},
     *     @OA\Response(
     *         response=200,
     *         description="Рекомендации успешно получены",
     *         @OA\JsonContent(
     *             @OA\Property(property="recommendations", type="array",
     *                 @OA\Items(type="string", example="Соблюдайте режим сна: ложитесь и просыпайтесь в одно и то же время каждый день.")
     *             )
     *         )
     *     )
     * )
     */
    public function getRecommendations(): JsonResponse
    {
        $recommendations = $this->sleepService->getRecommendations();

        return response()->json(['recommendations' => $recommendations]);
    }

    /**
     * @OA\Get(
     *     path="/api/sleep/stats",
     *     summary="Получение статистики сна",
     *     tags={"Sleep"},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         description="Период для анализа (week, month, year)",
     *         required=false,
     *         @OA\Schema(type="string", enum={"week", "month", "year"}, default="week")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Статистика успешно получена",
     *         @OA\JsonContent(
     *             @OA\Property(property="average_duration", type="integer", example=420, description="Средняя продолжительность сна в минутах"),
     *             @OA\Property(property="average_quality", type="string", example="Хороший сон", description="Среднее качество сна"),
     *             @OA\Property(property="longest_sleep", type="integer", example=540, description="Самый долгий сон в минутах"),
     *             @OA\Property(property="shortest_sleep", type="integer", example=300, description="Самый короткий сон в минутах"),
     *             @OA\Property(property="total_interruptions", type="integer", example=5, description="Общее количество прерываний"),
     *             @OA\Property(property="sleep_efficiency", type="number", example=87.5, description="Эффективность сна (%)"),
     *             @OA\Property(property="most_common_bedtime", type="string", example="23:30", description="Наиболее частое время отхода ко сну"),
     *             @OA\Property(property="best_sleep_day", type="string", example="Вторник", description="День с лучшим качеством сна")
     *         )
     *     )
     * )
     */
    public function getStatistics(Request $request): JsonResponse
    {
        $period = $request->input('period', 'week');
        $statistics = $this->sleepService->getStatistics($period);

        return response()->json($statistics);
    }

    /**
     * @OA\Get(
     *     path="/api/sleep/trends",
     *     summary="Получение тенденций сна",
     *     tags={"Sleep"},
     *     @OA\Parameter(
     *         name="months",
     *         in="query",
     *         description="Количество месяцев для анализа",
     *         required=false,
     *         @OA\Schema(type="integer", default=3)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Тенденции успешно получены",
     *         @OA\JsonContent(
     *             @OA\Property(property="duration_trend", type="string", example="increasing", description="Тенденция продолжительности сна"),
     *             @OA\Property(property="quality_trend", type="string", example="stable", description="Тенденция качества сна"),
     *             @OA\Property(property="interruptions_trend", type="string", example="decreasing", description="Тенденция прерываний сна"),
     *             @OA\Property(property="trend_data", type="object",
     *                 @OA\Property(property="labels", type="array", @OA\Items(type="string", example="Янв 2023")),
     *                 @OA\Property(property="duration", type="array", @OA\Items(type="integer", example=420)),
     *                 @OA\Property(property="quality_score", type="array", @OA\Items(type="integer", example=8)),
     *                 @OA\Property(property="interruptions", type="array", @OA\Items(type="integer", example=2))
     *             ),
     *             @OA\Property(property="insights", type="array", @OA\Items(type="string", example="Ваш сон улучшается по сравнению с прошлым месяцем."))
     *         )
     *     )
     * )
     */
    public function getTrends(Request $request): JsonResponse
    {
        $months = (int) $request->input('months', 3);
        $trends = $this->sleepService->getTrends($months);

        return response()->json($trends);
    }

    /**
     * @OA\Post(
     *     path="/api/sleep/goals",
     *     summary="Установка целей по сну",
     *     tags={"Sleep"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="target_hours", type="integer", example=8, description="Целевое количество часов сна"),
     *             @OA\Property(property="target_bedtime", type="string", format="time", example="23:00", description="Целевое время отхода ко сну"),
     *             @OA\Property(property="target_wake_time", type="string", format="time", example="07:00", description="Целевое время пробуждения"),
     *             @OA\Property(property="max_interruptions", type="integer", example=1, description="Максимальное количество допустимых прерываний")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Цели успешно установлены",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Цели по сну успешно установлены."),
     *             @OA\Property(property="goals", type="object")
     *         )
     *     )
     * )
     */
    public function setSleepGoals(SetSleepGoalRequest $request): JsonResponse
    {
        $goals = $this->sleepService->setSleepGoals($request->validated());

        return response()->json([
            'message' => 'Цели по сну успешно установлены.',
            'goals' => $goals
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/sleep/goals/progress",
     *     summary="Получение прогресса по целям сна",
     *     tags={"Sleep"},
     *     @OA\Response(
     *         response=200,
     *         description="Прогресс успешно получен",
     *         @OA\JsonContent(
     *             @OA\Property(property="progress", type="object",
     *                 @OA\Property(property="hours_progress", type="integer", example=85, description="Прогресс по часам сна (%)"),
     *                 @OA\Property(property="bedtime_adherence", type="integer", example=70, description="Соблюдение времени отхода ко сну (%)"),
     *                 @OA\Property(property="wake_time_adherence", type="integer", example=90, description="Соблюдение времени пробуждения (%)"),
     *                 @OA\Property(property="interruptions_success", type="integer", example=80, description="Успешность по прерываниям (%)"),
     *                 @OA\Property(property="overall_progress", type="integer", example=82, description="Общий прогресс (%)"),
     *                 @OA\Property(property="streak", type="integer", example=5, description="Текущая серия дней соблюдения целей")
     *             )
     *         )
     *     )
     * )
     */
    public function getGoalsProgress(): JsonResponse
    {
        $progress = $this->sleepService->getGoalsProgress();

        return response()->json(['progress' => $progress]);
    }

    /**
     * @OA\Post(
     *     path="/api/sleep/import",
     *     summary="Импорт данных о сне с устройств",
     *     tags={"Sleep"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="device_type", type="string", enum={"fitbit", "garmin", "apple_health", "samsung_health", "other"}, example="fitbit", description="Тип устройства"),
     *             @OA\Property(property="data", type="object", description="Данные с устройства в соответствующем формате")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные успешно импортированы",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Данные успешно импортированы."),
     *             @OA\Property(property="processed_entries", type="integer", example=7),
     *             @OA\Property(property="sleep_records", type="array", @OA\Items(type="object"))
     *         )
     *     )
     * )
     */
    public function importDeviceData(ImportDeviceDataRequest $request): JsonResponse
    {
        $result = $this->sleepService->importDeviceData($request->validated());

        return response()->json([
            'message' => 'Данные успешно импортированы.',
            'processed_entries' => $result['processed_entries'],
            'sleep_records' => $result['sleep_records']
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/sleep/correlations",
     *     summary="Получение корреляций между параметрами сна и другими факторами",
     *     tags={"Sleep"},
     *     @OA\Response(
     *         response=200,
     *         description="Корреляции успешно получены",
     *         @OA\JsonContent(
     *             @OA\Property(property="correlations", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="factor", type="string", example="Физическая активность"),
     *                     @OA\Property(property="correlation", type="number", example=0.78),
     *                     @OA\Property(property="impact", type="string", example="positive"),
     *                     @OA\Property(property="description", type="string", example="Дни с высокой физической активностью коррелируют с лучшим качеством сна.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getSleepCorrelations(): JsonResponse
    {
        $correlations = $this->sleepService->getSleepCorrelations();

        return response()->json(['correlations' => $correlations]);
    }
}
