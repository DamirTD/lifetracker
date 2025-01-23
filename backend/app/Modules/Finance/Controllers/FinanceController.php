<?php

namespace App\Modules\Finance\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use App\Modules\Finance\Requests\CalculateFinanceRequest;
use App\Modules\Finance\Requests\GetFinanceRecordsRequest;
use App\Modules\Finance\Requests\StoreFinanceRecordRequest;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;
use Illuminate\Http\JsonResponse;

class FinanceController extends Controller
{
    public function __construct(
      protected FinanceAdviceServiceInterface $adviceService,
      protected FinanceRecordQueryInterface $recordQuery
    ){
    }

    /**
     * @OA\Post(
     *     path="/api/finance/calculate",
     *     summary="Рассчитать распределение финансов",
     *     description="Рассчитывает распределение финансов по заданному правилу и зарплате.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"salary", "rule"},
     *             @OA\Property(
     *                 property="salary",
     *                 type="number",
     *                 format="float",
     *                 description="Зарплата пользователя."
     *             ),
     *             @OA\Property(
     *                 property="rule",
     *                 type="string",
     *                 enum={"50-30-20", "70-20-10", "80-10-10"},
     *                 description="Правило распределения финансов."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Успешный расчет",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="essentials", type="number", format="float", description="Сумма для базовых расходов."),
     *             @OA\Property(property="wants", type="number", format="float", description="Сумма для желаемых расходов."),
     *             @OA\Property(property="savings", type="number", format="float", description="Сумма для сбережений.")
     *         )
     *     )
     * )
     */
    public function calculateFinance(CalculateFinanceRequest $request): JsonResponse
    {
        $data = $request->validated();

        $response = $this->adviceService->calculateBreakdown($data['salary'], $data['rule']);

        return response()->json($response);
    }

    /**
     * @OA\Post(
     *     path="/api/finance/record",
     *     summary="Сохранить запись о финансах",
     *     description="Сохраняет новую запись о финансах.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"amount", "type", "period"},
     *             @OA\Property(
     *                 property="amount",
     *                 type="number",
     *                 format="float",
     *                 description="Сумма записи."
     *             ),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"expense", "saving"},
     *                 description="Тип записи (расход или сбережение)."
     *             ),
     *             @OA\Property(
     *                 property="period",
     *                 type="string",
     *                 enum={"week", "month", "year"},
     *                 description="Период записи."
     *             ),
     *             @OA\Property(
     *                 property="description",
     *                 type="string",
     *                 description="Описание записи (опционально)."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Запись успешно сохранена",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Запись успешно сохранена."),
     *             @OA\Property(
     *                 property="record",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", description="ID записи."),
     *                 @OA\Property(property="amount", type="number", format="float", description="Сумма."),
     *                 @OA\Property(property="type", type="string", description="Тип записи."),
     *                 @OA\Property(property="period", type="string", description="Период записи."),
     *                 @OA\Property(property="description", type="string", description="Описание записи.")
     *             )
     *         )
     *     )
     * )
     */
    public function storeFinanceRecord(StoreFinanceRecordRequest $request): JsonResponse
    {
        $record = $this->recordQuery->store($request->validated());

        return response()->json([
            'message' => 'Запись успешно сохранена.',
            'record'  => $record,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/records",
     *     summary="Получить записи о финансах",
     *     description="Возвращает записи о финансах за указанный период.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         required=true,
     *         description="Период записей (week, month, year).",
     *         @OA\Schema(type="string", enum={"week", "month", "year"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список записей",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="records",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", description="ID записи."),
     *                     @OA\Property(property="amount", type="number", format="float", description="Сумма."),
     *                     @OA\Property(property="type", type="string", description="Тип записи."),
     *                     @OA\Property(property="period", type="string", description="Период записи."),
     *                     @OA\Property(property="description", type="string", description="Описание записи.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getFinanceRecords(GetFinanceRecordsRequest $request): JsonResponse
    {
        $records = $this->recordQuery->
        getByUserAndPeriod(auth()->id(),
            $request->validated('period'));

        return response()->json(['records' => $records]);
    }
}
