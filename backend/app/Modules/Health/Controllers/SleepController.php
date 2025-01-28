<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\Requests\RecordSleepRequest;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

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
}
