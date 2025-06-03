<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Food;
use App\Modules\Health\Requests\AddFoodRequest;
use App\Modules\Health\Requests\GetDietRequest;
use App\Modules\Health\Requests\GetMonthlyRequest;
use App\Modules\Health\Requests\GetStatisticsRequest;
use App\Modules\Health\Requests\UpdateDietGoalsRequest;
use App\Modules\Health\Requests\UpdateFoodRequest;
use App\Modules\Health\Resources\FoodResource;
use App\Modules\Health\ServiceInterfaces\DietServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @OA\Schema(
 *     schema="DietEntry",
 *     required={"food_id", "quantity", "date", "meal_type", "calories", "protein", "fat", "carbohydrates"},
 *     @OA\Property(property="food_id", type="integer", example=1),
 *     @OA\Property(property="food_name", type="string", example="Chicken Breast"),
 *     @OA\Property(property="quantity", type="number", example=200),
 *     @OA\Property(property="date", type="string", format="date", example="2025-01-29"),
 *     @OA\Property(property="meal_type", type="string", enum={"breakfast", "lunch", "dinner", "snack"}, example="breakfast"),
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
     * @OA\Get(
     *     path="/api/diet/foods",
     *     summary="Получить список доступных продуктов с пагинацией",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="search",
     *         in="query",
     *         description="Поиск по названию продукта",
     *         required=false,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Parameter(
     *         name="page",
     *         in="query",
     *         description="Номер страницы",
     *         required=false,
     *         @OA\Schema(type="integer", default=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список продуктов с пагинацией",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="name", type="string", example="Chicken Breast"),
     *                     @OA\Property(property="calories", type="integer", example=165),
     *                     @OA\Property(property="protein", type="number", format="float", example=31.0),
     *                     @OA\Property(property="fat", type="number", format="float", example=3.6),
     *                     @OA\Property(property="carbohydrates", type="number", format="float", example=0)
     *                 )
     *             ),
     *             @OA\Property(
     *                 property="links",
     *                 type="object",
     *                 @OA\Property(property="first", type="string", example="http://example.com/api/diet/foods?page=1"),
     *                 @OA\Property(property="last", type="string", example="http://example.com/api/diet/foods?page=3"),
     *                 @OA\Property(property="prev", type="string", example=null),
     *                 @OA\Property(property="next", type="string", example="http://example.com/api/diet/foods?page=2")
     *             ),
     *             @OA\Property(
     *                 property="meta",
     *                 type="object",
     *                 @OA\Property(property="current_page", type="integer", example=1),
     *                 @OA\Property(property="from", type="integer", example=1),
     *                 @OA\Property(property="last_page", type="integer", example=3),
     *                 @OA\Property(property="path", type="string", example="http://example.com/api/diet/foods"),
     *                 @OA\Property(property="per_page", type="integer", example=15),
     *                 @OA\Property(property="to", type="integer", example=15),
     *                 @OA\Property(property="total", type="integer", example=45)
     *             )
     *         )
     *     )
     * )
     */
    public function getFoods(Request $request): JsonResponse
    {
        $search = $request->query('search');
        $foods = Food::search($search)
            ->orderBy('name')
            ->paginate(15);

        return response()->json(FoodResource::collection($foods));
    }

    /**
     * @OA\Post(
     *     path="/api/diet/food",
     *     summary="Добавить продукт в рацион",
     *     tags={"Diet"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"food_id", "quantity", "date", "meal_type"},
     *             @OA\Property(property="food_id", type="integer", example=1),
     *             @OA\Property(property="quantity", type="number", example=200),
     *             @OA\Property(property="date", type="string", format="date", example="2025-01-29"),
     *             @OA\Property(property="meal_type", type="string", enum={"breakfast", "lunch", "dinner", "snack"}, example="breakfast")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Продукт добавлен в рацион",
     *         @OA\JsonContent(
     *             @OA\Property(property="id", type="integer", example=1),
     *             @OA\Property(property="food_name", type="string", example="Chicken Breast"),
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
     *     @OA\Parameter(
     *         name="meal_type",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="string", enum={"breakfast", "lunch", "dinner", "snack"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Рацион на день",
     *         @OA\JsonContent(
     *             @OA\Property(property="date", type="string", example="2025-01-29"),
     *             @OA\Property(property="goal", type="object",
     *                 @OA\Property(property="calories", type="integer", example=2000),
     *                 @OA\Property(property="protein", type="integer", example=150),
     *                 @OA\Property(property="fat", type="integer", example=70),
     *                 @OA\Property(property="carbohydrates", type="integer", example=250)
     *             ),
     *             @OA\Property(property="total", type="object",
     *                 @OA\Property(property="calories", type="integer", example=1200),
     *                 @OA\Property(property="protein", type="integer", example=80),
     *                 @OA\Property(property="fat", type="integer", example=50),
     *                 @OA\Property(property="carbohydrates", type="integer", example=200)
     *             ),
     *             @OA\Property(property="remaining", type="object",
     *                 @OA\Property(property="calories", type="integer", example=800),
     *                 @OA\Property(property="protein", type="integer", example=70),
     *                 @OA\Property(property="fat", type="integer", example=20),
     *                 @OA\Property(property="carbohydrates", type="integer", example=50)
     *             ),
     *             @OA\Property(property="progress", type="object",
     *                 @OA\Property(property="calories", type="integer", example=60),
     *                 @OA\Property(property="protein", type="integer", example=53),
     *                 @OA\Property(property="fat", type="integer", example=71),
     *                 @OA\Property(property="carbohydrates", type="integer", example=80)
     *             ),
     *             @OA\Property(property="entries", type="array", @OA\Items(ref="#/components/schemas/DietEntry"))
     *         )
     *     ),
     *     @OA\Response(response=404, description="Данные не найдены")
     * )
     */
    public function getDailyDiet(GetDietRequest $request, $date): JsonResponse
    {
        $mealType = $request->query('meal_type');
        $diet = $this->dietService->getDailyDiet($date, $mealType);

        return response()->json($diet);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/weekly",
     *     summary="Получить рацион за неделю",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="date",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="string", format="date", example="2025-01-29")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Рацион за неделю",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(
     *                 @OA\Property(property="date", type="string", format="date", example="2025-01-22"),
     *                 @OA\Property(property="goal", type="object",
     *                     @OA\Property(property="calories", type="integer", example=2000),
     *                     @OA\Property(property="protein", type="integer", example=150),
     *                     @OA\Property(property="fat", type="integer", example=70),
     *                     @OA\Property(property="carbohydrates", type="integer", example=250)
     *                 ),
     *                 @OA\Property(property="total", type="object",
     *                     @OA\Property(property="calories", type="integer", example=1800),
     *                     @OA\Property(property="protein", type="integer", example=100),
     *                     @OA\Property(property="fat", type="integer", example=60),
     *                     @OA\Property(property="carbohydrates", type="integer", example=250)
     *                 ),
     *                 @OA\Property(property="progress", type="object",
     *                     @OA\Property(property="calories", type="integer", example=90),
     *                     @OA\Property(property="protein", type="integer", example=67),
     *                     @OA\Property(property="fat", type="integer", example=86),
     *                     @OA\Property(property="carbohydrates", type="integer", example=100)
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(response=404, description="Данные не найдены")
     * )
     */
    public function getWeeklyDiet(GetDietRequest $request): JsonResponse
    {
        $date = $request->query('date');
        $diet = $this->dietService->getWeeklyDiet($date);

        return response()->json($diet);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/monthly",
     *     summary="Получить статистику за месяц",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="year",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="integer", example=2025)
     *     ),
     *     @OA\Parameter(
     *         name="month",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Статистика за месяц",
     *         @OA\JsonContent(
     *             @OA\Property(property="year", type="integer", example=2025),
     *             @OA\Property(property="month", type="integer", example=1),
     *             @OA\Property(property="average", type="object",
     *                 @OA\Property(property="calories", type="integer", example=1850),
     *                 @OA\Property(property="protein", type="integer", example=120),
     *                 @OA\Property(property="fat", type="integer", example=65),
     *                 @OA\Property(property="carbohydrates", type="integer", example=230)
     *             ),
     *             @OA\Property(property="days", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="date", type="string", format="date", example="2025-01-01"),
     *                     @OA\Property(property="total", type="object",
     *                         @OA\Property(property="calories", type="integer", example=1800),
     *                         @OA\Property(property="protein", type="integer", example=100),
     *                         @OA\Property(property="fat", type="integer", example=60),
     *                         @OA\Property(property="carbohydrates", type="integer", example=250)
     *                     ),
     *                     @OA\Property(property="goal_achieved", type="boolean", example=true)
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getMonthlyDiet(GetMonthlyRequest $request): JsonResponse
    {
        $year = $request->query('year', now()->year);
        $month = $request->query('month', now()->month);

        $monthlyData = $this->dietService->getMonthlyDiet($year, $month);

        return response()->json($monthlyData);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/statistics",
     *     summary="Получить статистику питания",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         required=true,
     *         @OA\Schema(type="string", enum={"week", "month", "quarter", "year"}, example="month")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Статистика питания",
     *         @OA\JsonContent(
     *             @OA\Property(property="period", type="string", example="month"),
     *             @OA\Property(property="goal_achieved_days", type="integer", example=22),
     *             @OA\Property(property="total_days", type="integer", example=30),
     *             @OA\Property(property="success_rate", type="number", example=73.3),
     *             @OA\Property(property="average", type="object",
     *                 @OA\Property(property="calories", type="integer", example=1850),
     *                 @OA\Property(property="protein", type="integer", example=120),
     *                 @OA\Property(property="fat", type="integer", example=65),
     *                 @OA\Property(property="carbohydrates", type="integer", example=230)
     *             ),
     *             @OA\Property(property="progress", type="object",
     *                 @OA\Property(property="calories", type="array",
     *                     @OA\Items(type="integer")
     *                 ),
     *                 @OA\Property(property="protein", type="array",
     *                     @OA\Items(type="integer")
     *                 ),
     *                 @OA\Property(property="fat", type="array",
     *                     @OA\Items(type="integer")
     *                 ),
     *                 @OA\Property(property="carbohydrates", type="array",
     *                     @OA\Items(type="integer")
     *                 )
     *             ),
     *             @OA\Property(property="most_frequent_foods", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="name", type="string", example="Chicken Breast"),
     *                     @OA\Property(property="count", type="integer", example=15)
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getStatistics(GetStatisticsRequest $request): JsonResponse
    {
        $period = $request->query('period');

        $statistics = $this->dietService->getStatistics($period);

        return response()->json($statistics);
    }

    /**
     * @OA\Put(
     *     path="/api/diet/food/{id}",
     *     summary="Обновить запись в рационе",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="quantity", type="number", example=150),
     *             @OA\Property(property="meal_type", type="string", enum={"breakfast", "lunch", "dinner", "snack"}, example="lunch")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Запись обновлена",
     *         @OA\JsonContent(ref="#/components/schemas/DietEntry")
     *     ),
     *     @OA\Response(response=404, description="Запись не найдена"),
     *     @OA\Response(response=422, description="Невалидные данные")
     * )
     */
    public function updateFood(UpdateFoodRequest $request, $id): JsonResponse
    {
        $dietEntry = $this->dietService->updateFood($id, $request->validated());

        return response()->json($dietEntry);
    }

    /**
     * @OA\Delete(
     *     path="/api/diet/food/{id}",
     *     summary="Удалить запись из рациона",
     *     tags={"Diet"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=204,
     *         description="Запись удалена"
     *     ),
     *     @OA\Response(response=404, description="Запись не найдена")
     * )
     */
    public function deleteFood($id): JsonResponse
    {
        $this->dietService->deleteFood($id);

        return response()->json(null, HttpStatusCodes::NO_CONTENT);
    }

    /**
     * @OA\Get(
     *     path="/api/diet/goals",
     *     summary="Получить текущие цели питания",
     *     tags={"Diet"},
     *     @OA\Response(
     *         response=200,
     *         description="Цели питания",
     *         @OA\JsonContent(
     *             @OA\Property(property="calories", type="integer", example=2000),
     *             @OA\Property(property="protein", type="integer", example=150),
     *             @OA\Property(property="fat", type="integer", example=70),
     *             @OA\Property(property="carbohydrates", type="integer", example=250)
     *         )
     *     )
     * )
     */
    public function getDietGoals(): JsonResponse
    {
        $goals = $this->dietService->getDietGoals();

        return response()->json($goals);
    }

    /**
     * @OA\Put(
     *     path="/api/diet/goals",
     *     summary="Обновить цели питания",
     *     tags={"Diet"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="calories", type="integer", example=2000),
     *             @OA\Property(property="protein", type="integer", example=150),
     *             @OA\Property(property="fat", type="integer", example=70),
     *             @OA\Property(property="carbohydrates", type="integer", example=250)
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Цели обновлены",
     *         @OA\JsonContent(
     *             @OA\Property(property="calories", type="integer", example=2000),
     *             @OA\Property(property="protein", type="integer", example=150),
     *             @OA\Property(property="fat", type="integer", example=70),
     *             @OA\Property(property="carbohydrates", type="integer", example=250)
     *         )
     *     ),
     *     @OA\Response(response=422, description="Невалидные данные")
     * )
     */
    public function updateDietGoals(UpdateDietGoalsRequest $request): JsonResponse
    {
        $goals = $this->dietService->updateDietGoals($request->validated());

        return response()->json($goals);
    }
}
