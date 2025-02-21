<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\Requests\AddFoodRequest;
use App\Modules\Health\Requests\GetDietRequest;
use App\Modules\Health\ServiceInterfaces\DietServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="DietEntry",
 *     required={"food_id", "quantity", "date", "calories", "protein", "fat", "carbohydrates"},
 *     @OA\Property(property="food_id", type="integer", example=1),
 *     @OA\Property(property="quantity", type="number", example=200),
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29"),
 *     @OA\Property(property="calories", type="integer", example=300),
 *     @OA\Property(property="protein", type="integer", example=20),
 *     @OA\Property(property="fat", type="integer", example=10),
 *     @OA\Property(property="carbohydrates", type="integer", example=50)
 * )
 */
class DietController extends Controller
{

    public function __construct(
        protected DietServiceInterface $dietService
    ){
    }

    /**
     * @OA\Post(
     *     path="/api/diet/food",
     *     summary="Добавить продукт в рацион",
     *     tags={"Diet"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"food_id", "quantity", "date"},
     *             @OA\Property(property="food_id", type="integer", example=1),
     *             @OA\Property(property="quantity", type="number", example=200),
     *             @OA\Property(property="date", type="string", format="date", example="2025-01-29")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Продукт добавлен в рацион",
     *         @OA\JsonContent(
     *             @OA\Property(property="calories", type="integer", example=300),
     *             @OA\Property(property="protein", type="integer", example=20),
     *             @OA\Property(property="fat", type="integer", example=10),
     *             @OA\Property(property="carbohydrates", type="integer", example=50)
     *         )
     *     ),
     *     @OA\Response(response=422, description="Невалидные данные")
     * )
     */
    public function addFood(AddFoodRequest $request): JsonResponse
    {
        $dietEntry = $this->dietService->addFood($request->validated());

        return response()->json($dietEntry, HttpStatusCodes::CREATED);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/daily/{date}",
     *     summary="Получить рацион на день",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="date",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string", format="date", example="2025-01-29")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Рацион на день",
     *         @OA\JsonContent(
     *             @OA\Property(property="date", type="string", example="2025-01-29"),
     *             @OA\Property(property="total", type="object",
     *                 @OA\Property(property="calories", type="integer", example=1200),
     *                 @OA\Property(property="protein", type="integer", example=80),
     *                 @OA\Property(property="fat", type="integer", example=50),
     *                 @OA\Property(property="carbohydrates", type="integer", example=200)
     *             ),
     *             @OA\Property(property="entries", type="array", @OA\Items(ref="#/components/schemas/DietEntry"))
     *         )
     *     ),
     *     @OA\Response(response=404, description="Данные не найдены")
     * )
     */
    public function getDailyDiet(GetDietRequest $request, $date): JsonResponse
    {
        $diet = $this->dietService->getDailyDiet($date);

        return response()->json($diet);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/weekly",
     *     summary="Получить рацион за неделю",
     *     tags={"Diet"},
     *     @OA\Response(
     *         response=200,
     *         description="Рацион за неделю",
     *         @OA\JsonContent(
     *             @OA\Property(property="date", type="string", format="date", example="2025-01-22"),
     *             @OA\Property(property="calories", type="integer", example=1800),
     *             @OA\Property(property="protein", type="integer", example=100),
     *             @OA\Property(property="fat", type="integer", example=60),
     *             @OA\Property(property="carbohydrates", type="integer", example=250)
     *         )
     *     ),
     *     @OA\Response(response=404, description="Данные не найдены")
     * )
     */
    public function getWeeklyDiet(): JsonResponse
    {
        $diet = $this->dietService->getWeeklyDiet();

        return response()->json($diet);
    }
}
