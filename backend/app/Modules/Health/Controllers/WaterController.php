<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\DTO\WaterContainerDTO;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\DTO\WaterReminderDTO;
use App\Modules\Health\Requests\AddGlassRequest;
use App\Modules\Health\Requests\SaveContainerRequest;
use App\Modules\Health\Requests\SetDailyGoalRequest;
use App\Modules\Health\Requests\SetReminderRequest;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WaterController extends Controller
{
    public function __construct(
        protected WaterServiceInterface $waterService
    ){
    }

    /**
     * @OA\Get(
     *     path="/api/water/daily-consumption",
     *     summary="Получить ежедневное потребление воды",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="date",
     *         in="query",
     *         description="Дата для получения потребления (формат YYYY-MM-DD). По умолчанию - сегодня.",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные о потреблении воды за день.",
     *         @OA\JsonContent(
     *             @OA\Property(property="date", type="string", example="2025-01-27"),
     *             @OA\Property(property="consumed_ml", type="integer", example=1200),
     *             @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *             @OA\Property(property="percent_complete", type="integer", example=60),
     *             @OA\Property(property="hourly_data", type="object", example={"08": 200, "12": 400, "15": 600})
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getDailyConsumption(Request $request): JsonResponse
    {
        $date = $request->input('date');
        $result = $this->waterService->getDailyConsumption(auth()->id(), $date);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/weekly-consumption",
     *     summary="Получить потребление воды за неделю",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="start_date",
     *         in="query",
     *         description="Начальная дата недели (формат YYYY-MM-DD). По умолчанию - начало текущей недели.",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные о потреблении воды за неделю.",
     *         @OA\JsonContent(
     *             @OA\Property(property="start_date", type="string", example="2025-01-20"),
     *             @OA\Property(property="end_date", type="string", example="2025-01-26"),
     *             @OA\Property(property="consumed_ml", type="integer", example=8400),
     *             @OA\Property(property="goal_ml", type="integer", example=14000),
     *             @OA\Property(property="percent_complete", type="integer", example=60),
     *             @OA\Property(property="daily_data", type="array", @OA\Items(
     *                 @OA\Property(property="date", type="string", example="2025-01-20"),
     *                 @OA\Property(property="day_of_week", type="integer", example=1),
     *                 @OA\Property(property="day_name", type="string", example="Понедельник"),
     *                 @OA\Property(property="consumed_ml", type="integer", example=1200),
     *                 @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *                 @OA\Property(property="percent_complete", type="integer", example=60)
     *             ))
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getWeeklyConsumption(Request $request): JsonResponse
    {
        $startDate = $request->input('start_date');
        $result = $this->waterService->getWeeklyConsumption(auth()->id(), $startDate);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/monthly-consumption",
     *     summary="Получить потребление воды за месяц",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="year_month",
     *         in="query",
     *         description="Год и месяц (формат YYYY-MM). По умолчанию - текущий месяц.",
     *         required=false,
     *         @OA\Schema(type="string", example="2025-01")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные о потреблении воды за месяц.",
     *         @OA\JsonContent(
     *             @OA\Property(property="year_month", type="string", example="2025-01"),
     *             @OA\Property(property="month_name", type="string", example="Январь 2025"),
     *             @OA\Property(property="consumed_ml", type="integer", example=35000),
     *             @OA\Property(property="days_with_data", type="integer", example=20),
     *             @OA\Property(property="days_reached_goal", type="integer", example=15),
     *             @OA\Property(property="success_rate", type="integer", example=75),
     *             @OA\Property(property="average_daily_ml", type="integer", example=1750)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getMonthlyConsumption(Request $request): JsonResponse
    {
        $yearMonth = $request->input('year_month');
        $result = $this->waterService->getMonthlyConsumption(auth()->id(), $yearMonth);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Post(
     *     path="/api/water/set-daily-goal",
     *     summary="Установить дневную норму воды",
     *     tags={"Water"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/SetDailyGoalRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Дневная норма рассчитана и установлена.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Дневная норма рассчитана и установлена."),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *                 @OA\Property(property="glass_volume_ml", type="integer", example=200),
     *                 @OA\Property(property="recommended_glasses", type="integer", example=10),
     *                 @OA\Property(property="factors", type="object",
     *                     @OA\Property(property="weight_factor", type="number", example=30),
     *                     @OA\Property(property="height_factor", type="number", example=1.1),
     *                     @OA\Property(property="activity_factor", type="number", example=1.3),
     *                     @OA\Property(property="climate_factor", type="number", example=1.0)
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Validation error."),
     *             @OA\Property(property="errors", type="array", @OA\Items(type="string", example="Поле weight обязательно."))
     *         )
     *     )
     * )
     */
    public function setDailyGoal(SetDailyGoalRequest $request): JsonResponse
    {
        return $this->wrap($request, function () use ($request) {
            $dto = new WaterGoalDTO(
                $request->input('weight'),
                $request->input('height'),
                $request->input('goal'),
                $request->input('glass_volume_ml'),
                $request->input('activity_level', 'moderate'),
                $request->input('climate', 'moderate')
            );

            $result = $this->waterService->calculateDailyGoal($dto);

            return [
                'message' => 'Дневная норма рассчитана и установлена.',
                'data'    => $result,
            ];
        });
    }

    /**
     * @OA\Post(
     *     path="/api/water/add-glass",
     *     summary="Добавить стакан воды",
     *     tags={"Water"},
     *     @OA\RequestBody(
     *         required=false,
     *         @OA\JsonContent(
     *             @OA\Property(property="container_id", type="integer", example=1, description="ID контейнера (необязательно)"),
     *             @OA\Property(property="volume_ml", type="integer", example=300, description="Произвольный объем (необязательно)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Стакан добавлен успешно.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Стакан воды добавлен!"),
     *             @OA\Property(property="consumed_ml", type="integer", example=1000),
     *             @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *             @OA\Property(property="remaining_ml", type="integer", example=1000),
     *             @OA\Property(property="glasses_today", type="integer", example=5),
     *             @OA\Property(property="glasses_volume_ml", type="integer", example=200),
     *             @OA\Property(property="last_added_at", type="string", format="date-time", example="2025-01-27T12:34:56"),
     *             @OA\Property(property="percent_complete", type="integer", example=50),
     *             @OA\Property(property="achievements", type="array", @OA\Items(
     *                 @OA\Property(property="id", type="string", example="half_daily_goal"),
     *                 @OA\Property(property="name", type="string", example="На полпути"),
     *                 @OA\Property(property="description", type="string", example="Вы достигли половины дневной нормы!"),
     *                 @OA\Property(property="icon", type="string", example="🌊")
     *             ))
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function addGlass(AddGlassRequest $request): JsonResponse
    {
        $userId = auth()->id();
        $containerId = $request->input('container_id');
        $volumeMl = $request->input('volume_ml');

        $result = $this->waterService->addGlass($userId, $containerId, $volumeMl);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Post(
     *     path="/api/water/remove-glass",
     *     summary="Удалить последний добавленный стакан воды",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Стакан удален успешно.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Стакан удален!"),
     *             @OA\Property(property="consumed_ml", type="integer", example=800),
     *             @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *             @OA\Property(property="remaining_ml", type="integer", example=1200),
     *             @OA\Property(property="glasses_today", type="integer", example=4),
     *             @OA\Property(property="glasses_volume_ml", type="integer", example=200),
     *             @OA\Property(property="percent_complete", type="integer", example=40)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Нет стаканов для удаления.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Нет добавленных стаканов воды за сегодня.")
     *         )
     *     )
     * )
     */
    public function removeGlass(): JsonResponse
    {
        $userId = auth()->id();
        $result = $this->waterService->removeGlass($userId);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/daily-stats",
     *     summary="Получить статистику за день",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Статистика за день успешно получена.",
     *         @OA\JsonContent(
     *             @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *             @OA\Property(property="consumed_ml", type="integer", example=1200),
     *             @OA\Property(property="remaining_ml", type="integer", example=800),
     *             @OA\Property(property="glasses_drunk", type="integer", example=6),
     *             @OA\Property(property="percent_complete", type="integer", example=60),
     *             @OA\Property(property="hourly_consumption", type="object", example={"08": 200, "12": 400, "15": 600}),
     *             @OA\Property(property="last_added_at", type="string", format="date-time", example="2025-01-27T15:30:00"),
     *             @OA\Property(property="streak", type="integer", example=5)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getDailyStats(): JsonResponse
    {
        $result = $this->waterService->getDailyStats(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/overall-stats",
     *     summary="Получить общую статистику",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Общая статистика успешно получена.",
     *         @OA\JsonContent(
     *             @OA\Property(property="total_ml", type="integer", example=100000),
     *             @OA\Property(property="total_days", type="integer", example=50),
     *             @OA\Property(property="days_reached_goal", type="integer", example=35),
     *             @OA\Property(property="success_rate", type="integer", example=70),
     *             @OA\Property(property="average_daily_ml", type="integer", example=2000),
     *             @OA\Property(property="day_of_week_stats", type="object"),
     *             @OA\Property(property="current_streak", type="integer", example=7),
     *             @OA\Property(property="best_streak", type="integer", example=14),
     *             @OA\Property(property="equivalent_water_bottles", type="integer", example=200),
     *             @OA\Property(property="water_saved_vs_bottled", type="integer", example=400)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getOverallStats(): JsonResponse
    {
        $result = $this->waterService->getOverallStats(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/history",
     *     summary="Получить историю потребления воды",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="start_date",
     *         in="query",
     *         description="Начальная дата (формат YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="end_date",
     *         in="query",
     *         description="Конечная дата (формат YYYY-MM-DD)",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Количество записей на странице",
     *         required=false,
     *         @OA\Schema(type="integer", default=10)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="История потребления воды успешно получена."
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getHistory(Request $request): JsonResponse
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $perPage = $request->input('per_page', 10);

        $result = $this->waterService->getHistory(auth()->id(), $startDate, $endDate, $perPage);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Post(
     *     path="/api/water/save-container",
     *     summary="Сохранить пользовательский контейнер",
     *     tags={"Water"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/SaveContainerRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Контейнер успешно сохранен.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Контейнер создан!"),
     *             @OA\Property(property="container", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Большая кружка"),
     *                 @OA\Property(property="volume_ml", type="integer", example=350),
     *                 @OA\Property(property="icon", type="string", example="mug"),
     *                 @OA\Property(property="color", type="string", example="#3498db"),
     *                 @OA\Property(property="is_default", type="boolean", example=false)
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Validation error."),
     *             @OA\Property(property="errors", type="array", @OA\Items(type="string", example="Название контейнера обязательно."))
     *         )
     *     )
     * )
     */
    public function saveContainer(SaveContainerRequest $request): JsonResponse
    {
        $dto = new WaterContainerDTO(
            $request->input('id'),
            $request->input('name'),
            $request->input('volume_ml'),
            $request->input('icon'),
            $request->input('color'),
            $request->input('is_default', false)
        );

        $result = $this->waterService->saveContainer(auth()->id(), $dto);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/containers",
     *     summary="Получить список контейнеров пользователя",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Список контейнеров успешно получен.",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Большая кружка"),
     *                 @OA\Property(property="volume_ml", type="integer", example=350),
     *                 @OA\Property(property="icon", type="string", example="mug"),
     *                 @OA\Property(property="color", type="string", example="#3498db"),
     *                 @OA\Property(property="is_default", type="boolean", example=false)
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getContainers(): JsonResponse
    {
        $result = $this->waterService->getContainers(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Delete(
     *     path="/api/water/containers/{id}",
     *     summary="Удалить контейнер",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         description="ID контейнера",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Контейнер успешно удален.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Контейнер удален!")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Контейнер не найден.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Контейнер не найден.")
     *         )
     *     )
     * )
     */
    public function deleteContainer(int $id): JsonResponse
    {
        $result = $this->waterService->deleteContainer(auth()->id(), $id);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Post(
     *     path="/api/water/set-reminder",
     *     summary="Установить напоминание о питье воды",
     *     tags={"Water"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/SetReminderRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Напоминание успешно установлено.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Напоминание создано!"),
     *             @OA\Property(property="reminder", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="start_time", type="string", example="08:00:00"),
     *                 @OA\Property(property="end_time", type="string", example="20:00:00"),
     *                 @OA\Property(property="interval_minutes", type="integer", example=60),
     *                 @OA\Property(property="days_of_week", type="array", @OA\Items(type="integer", example=1)),
     *                 @OA\Property(property="is_enabled", type="boolean", example=true),
     *                 @OA\Property(property="message", type="string", example="Пора выпить стакан воды!")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Validation error."),
     *             @OA\Property(property="errors", type="array", @OA\Items(type="string", example="Время начала обязательно."))
     *         )
     *     )
     * )
     */
    public function setReminder(SetReminderRequest $request): JsonResponse
    {
        $dto = new WaterReminderDTO(
            $request->input('id'),
            $request->input('start_time'),
            $request->input('end_time'),
            $request->input('interval_minutes'),
            $request->input('days_of_week'),
            $request->input('is_enabled', true),
            $request->input('message')
        );

        $result = $this->waterService->setReminder(auth()->id(), $dto);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/reminders",
     *     summary="Получить список напоминаний",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Список напоминаний успешно получен.",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="start_time", type="string", example="08:00:00"),
     *                 @OA\Property(property="end_time", type="string", example="20:00:00"),
     *                 @OA\Property(property="interval_minutes", type="integer", example=60),
     *                 @OA\Property(property="days_of_week", type="array", @OA\Items(type="integer", example=1)),
     *                 @OA\Property(property="is_enabled", type="boolean", example=true),
     *                 @OA\Property(property="message", type="string", example="Пора выпить стакан воды!")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getReminders(): JsonResponse
    {
        $result = $this->waterService->getReminders(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Delete(
     *     path="/api/water/reminders/{id}",
     *     summary="Удалить напоминание",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         description="ID напоминания",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Напоминание успешно удалено.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Напоминание удалено!")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Напоминание не найдено.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Напоминание не найдено.")
     *         )
     *     )
     * )
     */
    public function deleteReminder(int $id): JsonResponse
    {
        $result = $this->waterService->deleteReminder(auth()->id(), $id);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Put(
     *     path="/api/water/reminders/{id}/toggle",
     *     summary="Включить/выключить напоминание",
     *     tags={"Water"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         description="ID напоминания",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="is_enabled", type="boolean", example=true)
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Статус напоминания успешно изменен.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Напоминание включено!"),
     *             @OA\Property(property="reminder", type="object")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Напоминание не найдено.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Напоминание не найдено.")
     *         )
     *     )
     * )
     */
    public function toggleReminder(int $id, Request $request): JsonResponse
    {
        $isEnabled = $request->input('is_enabled', true);
        $result = $this->waterService->toggleReminder(auth()->id(), $id, $isEnabled);

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/insights",
     *     summary="Получить аналитические рекомендации по потреблению воды",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Рекомендации успешно получены.",
     *         @OA\JsonContent(
     *             @OA\Property(property="hourly_patterns", type="object"),
     *             @OA\Property(property="peak_hour", type="string", example="13"),
     *             @OA\Property(property="insights", type="array", @OA\Items(
     *                 @OA\Property(property="type", type="string", example="morning_hydration"),
     *                 @OA\Property(property="message", type="string", example="Вы пьете мало воды утром. Попробуйте выпивать стакан воды сразу после пробуждения."),
     *                 @OA\Property(property="priority", type="string", example="high")
     *             ))
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getInsights(): JsonResponse
    {
        $result = $this->waterService->getConsumptionInsights(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/comparison",
     *     summary="Сравнение с другими пользователями",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Сравнение успешно получено.",
     *         @OA\JsonContent(
     *             @OA\Property(property="user_average_ml", type="integer", example=2100),
     *             @OA\Property(property="global_average_ml", type="integer", example=1800),
     *             @OA\Property(property="percentile", type="integer", example=75),
     *             @OA\Property(property="above_average", type="boolean", example=true)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getComparison(): JsonResponse
    {
        $result = $this->waterService->getComparison(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    /**
     * @OA\Get(
     *     path="/api/water/eco-report",
     *     summary="Получить экологический отчет",
     *     tags={"Water"},
     *     @OA\Response(
     *         response=200,
     *         description="Экологический отчет успешно получен.",
     *         @OA\JsonContent(
     *             @OA\Property(property="bottles_saved", type="integer", example=200),
     *             @OA\Property(property="plastic_saved_g", type="integer", example=3000),
     *             @OA\Property(property="co2_saved_g", type="integer", example=18000),
     *             @OA\Property(property="water_saved_l", type="integer", example=600),
     *             @OA\Property(property="trees_equivalent", type="number", example=0.9)
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Неавторизованный запрос.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User is not authenticated.")
     *         )
     *     )
     * )
     */
    public function getEcoReport(): JsonResponse
    {
        $result = $this->waterService->getEcoReport(auth()->id());

        return response()->json($result['data'], $result['status']);
    }
}
