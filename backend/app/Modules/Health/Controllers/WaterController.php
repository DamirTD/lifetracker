<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\Requests\SetDailyGoalRequest;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use Illuminate\Http\JsonResponse;

class WaterController extends Controller
{

    public function __construct(
        protected WaterServiceInterface $waterService
    ){
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
     *                 @OA\Property(property="recommended_glasses", type="integer", example=10)
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
                $request->input('glass_volume_ml')
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
     *     @OA\Response(
     *         response=200,
     *         description="Стакан добавлен успешно.",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Стакан воды добавлен."),
     *             @OA\Property(property="remaining_ml", type="integer", example=1800),
     *             @OA\Property(property="glasses_today", type="integer", example=1)
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
    public function addGlass(): JsonResponse
    {
        $userId = auth()->id();

        $result = $this->waterService->addGlass($userId);

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
     *             @OA\Property(property="total_consumed_ml", type="integer", example=400),
     *             @OA\Property(property="daily_goal_ml", type="integer", example=2000),
     *             @OA\Property(property="remaining_ml", type="integer", example=1600)
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
     *             @OA\Property(property="total_consumed_ml", type="integer", example=100000),
     *             @OA\Property(property="days_tracked", type="integer", example=50),
     *             @OA\Property(property="average_daily_ml", type="integer", example=2000)
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
}
