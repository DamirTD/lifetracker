<?php

namespace App\Modules\Finance\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use App\Modules\Finance\Requests\CalculateFinanceRequest;
use App\Modules\Finance\Requests\GetFinanceRecordsRequest;
use App\Modules\Finance\Requests\StoreFinanceRecordRequest;
use App\Modules\Finance\Requests\GetFinanceStatisticsRequest;
use App\Modules\Finance\Requests\CreateBudgetRequest;
use App\Modules\Finance\Requests\GetBudgetRequest;
use App\Modules\Finance\Requests\SetFinancialGoalRequest;
use App\Modules\Finance\Requests\GetFinancialGoalsRequest;
use App\Modules\Finance\Requests\DeleteFinanceRecordRequest;
use App\Modules\Finance\Requests\ExportFinanceDataRequest;
use App\Modules\Finance\Requests\ImportFinanceDataRequest;
use App\Modules\Finance\Requests\CreateCategoryRequest;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceStatisticsServiceInterface;
use App\Modules\Finance\ServiceInterfaces\BudgetServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinancialGoalServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceExportServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceImportServiceInterface;
use App\Modules\Finance\ServiceInterfaces\CategoryServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FinanceController extends Controller
{
    public function __construct(
        protected FinanceAdviceServiceInterface $adviceService,
        protected FinanceRecordQueryInterface $recordQuery,
        protected FinanceStatisticsServiceInterface $statisticsService,
        protected BudgetServiceInterface $budgetService,
        protected FinancialGoalServiceInterface $goalService,
        protected FinanceExportServiceInterface $exportService,
        protected FinanceImportServiceInterface $importService,
        protected CategoryServiceInterface $categoryService
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
     *                 enum={"50-30-20", "70-20-10", "80-10-10", "60-20-20"},
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
     *             @OA\Property(property="savings", type="number", format="float", description="Сумма для сбережений."),
     *             @OA\Property(
     *                 property="advice",
     *                 type="array",
     *                 @OA\Items(type="string"),
     *                 description="Советы по финансовому планированию."
     *             )
     *         )
     *     )
     * )
     */
    public function calculateFinance(CalculateFinanceRequest $request): JsonResponse
    {
        $data = $request->validated();

        $response = $this->adviceService->calculateBreakdown($data['salary'], $data['rule']);
        $response['advice'] = $this->adviceService->getAdvice($data['rule']);

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
     *             required={"amount", "type", "period", "category_id"},
     *             @OA\Property(
     *                 property="amount",
     *                 type="number",
     *                 format="float",
     *                 description="Сумма записи."
     *             ),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"expense", "income", "saving", "investment"},
     *                 description="Тип записи (расход, доход, сбережение или инвестиция)."
     *             ),
     *             @OA\Property(
     *                 property="period",
     *                 type="string",
     *                 enum={"day", "week", "month", "year"},
     *                 description="Период записи."
     *             ),
     *             @OA\Property(
     *                 property="category_id",
     *                 type="integer",
     *                 description="ID категории."
     *             ),
     *             @OA\Property(
     *                 property="date",
     *                 type="string",
     *                 format="date",
     *                 description="Дата записи (опционально, по умолчанию текущая дата)."
     *             ),
     *             @OA\Property(
     *                 property="description",
     *                 type="string",
     *                 description="Описание записи (опционально)."
     *             ),
     *             @OA\Property(
     *                 property="is_recurring",
     *                 type="boolean",
     *                 description="Является ли запись регулярной (опционально)."
     *             ),
     *             @OA\Property(
     *                 property="recurring_frequency",
     *                 type="string",
     *                 enum={"daily", "weekly", "monthly", "yearly"},
     *                 description="Частота повторения для регулярных записей (опционально)."
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
     *                 @OA\Property(property="category_id", type="integer", description="ID категории."),
     *                 @OA\Property(property="date", type="string", format="date", description="Дата записи."),
     *                 @OA\Property(property="description", type="string", description="Описание записи."),
     *                 @OA\Property(property="is_recurring", type="boolean", description="Является ли запись регулярной."),
     *                 @OA\Property(property="recurring_frequency", type="string", description="Частота повторения.")
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
     *     description="Возвращает записи о финансах за указанный период с возможностью фильтрации и сортировки.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         required=false,
     *         description="Период записей (day, week, month, year).",
     *         @OA\Schema(type="string", enum={"day", "week", "month", "year"})
     *     ),
     *     @OA\Parameter(
     *         name="type",
     *         in="query",
     *         required=false,
     *         description="Тип записей (expense, income, saving, investment).",
     *         @OA\Schema(type="string", enum={"expense", "income", "saving", "investment"})
     *     ),
     *     @OA\Parameter(
     *         name="category_id",
     *         in="query",
     *         required=false,
     *         description="ID категории для фильтрации.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="start_date",
     *         in="query",
     *         required=false,
     *         description="Начальная дата для фильтрации (YYYY-MM-DD).",
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="end_date",
     *         in="query",
     *         required=false,
     *         description="Конечная дата для фильтрации (YYYY-MM-DD).",
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="sort_by",
     *         in="query",
     *         required=false,
     *         description="Поле для сортировки (amount, date, created_at).",
     *         @OA\Schema(type="string", enum={"amount", "date", "created_at"})
     *     ),
     *     @OA\Parameter(
     *         name="sort_direction",
     *         in="query",
     *         required=false,
     *         description="Направление сортировки (asc, desc).",
     *         @OA\Schema(type="string", enum={"asc", "desc"})
     *     ),
     *     @OA\Parameter(
     *         name="page",
     *         in="query",
     *         required=false,
     *         description="Номер страницы для пагинации.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         required=false,
     *         description="Количество записей на странице.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список записей",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="records",
     *                 type="object",
     *                 @OA\Property(property="current_page", type="integer"),
     *                 @OA\Property(property="data", type="array",
     *                     @OA\Items(
     *                         type="object",
     *                         @OA\Property(property="id", type="integer", description="ID записи."),
     *                         @OA\Property(property="amount", type="number", format="float", description="Сумма."),
     *                         @OA\Property(property="type", type="string", description="Тип записи."),
     *                         @OA\Property(property="period", type="string", description="Период записи."),
     *                         @OA\Property(property="category_id", type="integer", description="ID категории."),
     *                         @OA\Property(property="category_name", type="string", description="Название категории."),
     *                         @OA\Property(property="date", type="string", format="date", description="Дата записи."),
     *                         @OA\Property(property="description", type="string", description="Описание записи."),
     *                         @OA\Property(property="is_recurring", type="boolean", description="Является ли запись регулярной."),
     *                         @OA\Property(property="recurring_frequency", type="string", description="Частота повторения.")
     *                     )
     *                 ),
     *                 @OA\Property(property="first_page_url", type="string"),
     *                 @OA\Property(property="from", type="integer"),
     *                 @OA\Property(property="last_page", type="integer"),
     *                 @OA\Property(property="last_page_url", type="string"),
     *                 @OA\Property(property="next_page_url", type="string"),
     *                 @OA\Property(property="path", type="string"),
     *                 @OA\Property(property="per_page", type="integer"),
     *                 @OA\Property(property="prev_page_url", type="string"),
     *                 @OA\Property(property="to", type="integer"),
     *                 @OA\Property(property="total", type="integer")
     *             ),
     *             @OA\Property(
     *                 property="summary",
     *                 type="object",
     *                 @OA\Property(property="total_income", type="number", format="float"),
     *                 @OA\Property(property="total_expense", type="number", format="float"),
     *                 @OA\Property(property="total_saving", type="number", format="float"),
     *                 @OA\Property(property="total_investment", type="number", format="float"),
     *                 @OA\Property(property="balance", type="number", format="float")
     *             )
     *         )
     *     )
     * )
     */
    public function getFinanceRecords(GetFinanceRecordsRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $records = $this->recordQuery->getFilteredRecords(
            $userId,
            $data['period'] ?? null,
            $data['type'] ?? null,
            $data['category_id'] ?? null,
            $data['start_date'] ?? null,
            $data['end_date'] ?? null,
            $data['sort_by'] ?? 'date',
            $data['sort_direction'] ?? 'desc',
            $data['page'] ?? 1,
            $data['per_page'] ?? 15
        );

        $summary = $this->statisticsService->getSummary(
            $userId,
            $data['period'] ?? null,
            $data['start_date'] ?? null,
            $data['end_date'] ?? null
        );

        return response()->json([
            'records' => $records,
            'summary' => $summary
        ]);
    }

    /**
     * @OA\Put(
     *     path="/api/finance/record/{id}",
     *     summary="Обновить запись о финансах",
     *     description="Обновляет запись о финансах по указанному ID.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID записи для обновления.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="amount",
     *                 type="number",
     *                 format="float",
     *                 description="Сумма записи."
     *             ),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"expense", "income", "saving", "investment"},
     *                 description="Тип записи."
     *             ),
     *             @OA\Property(
     *                 property="period",
     *                 type="string",
     *                 enum={"day", "week", "month", "year"},
     *                 description="Период записи."
     *             ),
     *             @OA\Property(
     *                 property="category_id",
     *                 type="integer",
     *                 description="ID категории."
     *             ),
     *             @OA\Property(
     *                 property="date",
     *                 type="string",
     *                 format="date",
     *                 description="Дата записи."
     *             ),
     *             @OA\Property(
     *                 property="description",
     *                 type="string",
     *                 description="Описание записи."
     *             ),
     *             @OA\Property(
     *                 property="is_recurring",
     *                 type="boolean",
     *                 description="Является ли запись регулярной."
     *             ),
     *             @OA\Property(
     *                 property="recurring_frequency",
     *                 type="string",
     *                 enum={"daily", "weekly", "monthly", "yearly"},
     *                 description="Частота повторения для регулярных записей."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Запись успешно обновлена.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Запись успешно обновлена."),
     *             @OA\Property(
     *                 property="record",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", description="ID записи."),
     *                 @OA\Property(property="amount", type="number", format="float", description="Сумма после обновления."),
     *                 @OA\Property(property="type", type="string", description="Тип записи."),
     *                 @OA\Property(property="period", type="string", description="Период записи."),
     *                 @OA\Property(property="category_id", type="integer", description="ID категории."),
     *                 @OA\Property(property="date", type="string", format="date", description="Дата записи."),
     *                 @OA\Property(property="description", type="string", description="Описание записи."),
     *                 @OA\Property(property="is_recurring", type="boolean", description="Является ли запись регулярной."),
     *                 @OA\Property(property="recurring_frequency", type="string", description="Частота повторения.")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Запись не найдена.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Запись не найдена.")
     *         )
     *     )
     * )
     */
    public function updateFinanceRecord($id, StoreFinanceRecordRequest $request): JsonResponse
    {
        $record = $this->recordQuery->findByIdAndUser($id, auth()->id());

        if (!$record) {
            return response()->json(['message' => 'Запись не найдена.'], HttpStatusCodes::NOT_FOUND);
        }

        $record = $this->recordQuery->update($id, $request->validated());

        return response()->json([
            'message' => 'Запись успешно обновлена.',
            'record'  => $record,
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/api/finance/record/{id}",
     *     summary="Удалить запись о финансах",
     *     description="Удаляет запись о финансах по указанному ID.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID записи для удаления.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Запись успешно удалена.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Запись успешно удалена.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Запись не найдена.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Запись не найдена.")
     *         )
     *     )
     * )
     */
    public function deleteFinanceRecord($id, DeleteFinanceRecordRequest $request): JsonResponse
    {
        $record = $this->recordQuery->findByIdAndUser($id, auth()->id());

        if (!$record) {
            return response()->json(['message' => 'Запись не найдена.'], HttpStatusCodes::NOT_FOUND);
        }

        $this->recordQuery->delete($id);

        return response()->json([
            'message' => 'Запись успешно удалена.'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/statistics",
     *     summary="Получить статистику по финансам",
     *     description="Возвращает статистику по финансам за указанный период.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         required=false,
     *         description="Период статистики (day, week, month, year, custom).",
     *         @OA\Schema(type="string", enum={"day", "week", "month", "year", "custom"})
     *     ),
     *     @OA\Parameter(
     *         name="type",
     *         in="query",
     *         required=false,
     *         description="Тип статистики (expense, income, saving, investment).",
     *         @OA\Schema(type="string", enum={"expense", "income", "saving", "investment"})
     *     ),
     *     @OA\Parameter(
     *         name="start_date",
     *         in="query",
     *         required=false,
     *         description="Начальная дата для периода custom (YYYY-MM-DD).",
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="end_date",
     *         in="query",
     *         required=false,
     *         description="Конечная дата для периода custom (YYYY-MM-DD).",
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="group_by",
     *         in="query",
     *         required=false,
     *         description="Группировка статистики (day, week, month, year, category).",
     *         @OA\Schema(type="string", enum={"day", "week", "month", "year", "category"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Статистика по финансам",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="summary",
     *                 type="object",
     *                 @OA\Property(property="total_income", type="number", format="float"),
     *                 @OA\Property(property="total_expense", type="number", format="float"),
     *                 @OA\Property(property="total_saving", type="number", format="float"),
     *                 @OA\Property(property="total_investment", type="number", format="float"),
     *                 @OA\Property(property="balance", type="number", format="float"),
     *                 @OA\Property(property="saving_rate", type="number", format="float"),
     *                 @OA\Property(property="expense_rate", type="number", format="float")
     *             ),
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="period", type="string", description="Период (день, неделя, месяц, год или категория)."),
     *                     @OA\Property(property="amount", type="number", format="float", description="Сумма."),
     *                     @OA\Property(property="count", type="integer", description="Количество записей.")
     *                 )
     *             ),
     *             @OA\Property(
     *                 property="trends",
     *                 type="object",
     *                 @OA\Property(property="income_trend", type="number", format="float", description="Тренд доходов (% изменения)."),
     *                 @OA\Property(property="expense_trend", type="number", format="float", description="Тренд расходов (% изменения)."),
     *                 @OA\Property(property="saving_trend", type="number", format="float", description="Тренд сбережений (% изменения)."),
     *                 @OA\Property(property="investment_trend", type="number", format="float", description="Тренд инвестиций (% изменения).")
     *             ),
     *             @OA\Property(
     *                 property="category_breakdown",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="category_id", type="integer", description="ID категории."),
     *                     @OA\Property(property="category_name", type="string", description="Название категории."),
     *                     @OA\Property(property="amount", type="number", format="float", description="Сумма."),
     *                     @OA\Property(property="percentage", type="number", format="float", description="Процент от общей суммы.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getFinanceStatistics(GetFinanceStatisticsRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $statistics = $this->statisticsService->getStatistics(
            $userId,
            $data['period'] ?? 'month',
            $data['type'] ?? null,
            $data['start_date'] ?? null,
            $data['end_date'] ?? null,
            $data['group_by'] ?? 'day'
        );

        return response()->json($statistics);
    }

    public function createBudget(CreateBudgetRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $budget = $this->budgetService->createOrUpdate(
            $userId,
            $data['category_id'],
            $data['amount'],
            $data['period'],
            $data['start_date'] ?? null,
            $data['end_date'] ?? null
        );

        return response()->json([
            'message' => 'Бюджет успешно создан.',
            'budget'  => $budget,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/budgets",
     *     summary="Получить бюджеты",
     *     description="Возвращает бюджеты пользователя с возможностью фильтрации по периоду и категории.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="period",
     *         in="query",
     *         required=false,
     *         description="Период бюджета (week, month, year).",
     *         @OA\Schema(type="string", enum={"week", "month", "year"})
     *     ),
     *     @OA\Parameter(
     *         name="category_id",
     *         in="query",
     *         required=false,
     *         description="ID категории для фильтрации.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список бюджетов",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="budgets",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", description="ID бюджета."),
     *                     @OA\Property(property="category_id", type="integer", description="ID категории."),
     *                     @OA\Property(property="category_name", type="string", description="Название категории."),
     *                     @OA\Property(property="amount", type="number", format="float", description="Сумма бюджета."),
     *                     @OA\Property(property="spent", type="number", format="float", description="Потрачено по бюджету."),
     *                     @OA\Property(property="remaining", type="number", format="float", description="Остаток по бюджету."),
     *                     @OA\Property(property="percentage_used", type="number", format="float", description="Процент использования бюджета."),
     *                     @OA\Property(property="period", type="string", description="Период бюджета."),
     *                     @OA\Property(property="start_date", type="string", format="date", description="Начальная дата бюджета."),
     *                     @OA\Property(property="end_date", type="string", format="date", description="Конечная дата бюджета.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getBudgets(GetBudgetRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $budgets = $this->budgetService->getBudgets(
            $userId,
            $data['period'] ?? null,
            $data['category_id'] ?? null
        );

        return response()->json([
            'budgets' => $budgets
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/finance/goal",
     *     summary="Создать финансовую цель",
     *     description="Создает новую финансовую цель.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"name", "target_amount", "target_date"},
     *             @OA\Property(
     *                 property="name",
     *                 type="string",
     *                 description="Название цели."
     *             ),
     *             @OA\Property(
     *                 property="target_amount",
     *                 type="number",
     *                 format="float",
     *                 description="Целевая сумма."
     *             ),
     *             @OA\Property(
     *                 property="target_date",
     *                 type="string",
     *                 format="date",
     *                 description="Целевая дата достижения."
     *             ),
     *             @OA\Property(
     *                 property="current_amount",
     *                 type="number",
     *                 format="float",
     *                 description="Текущая накопленная сумма (опционально)."
     *             ),
     *             @OA\Property(
     *                 property="description",
     *                 type="string",
     *                 description="Описание цели (опционально)."
     *             ),
     *             @OA\Property(
     *                 property="priority",
     *                 type="string",
     *                 enum={"low", "medium", "high"},
     *                 description="Приоритет цели (опционально)."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Цель успешно создана.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Финансовая цель успешно создана."),
     *             @OA\Property(
     *                 property="goal",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", description="ID цели."),
     *                 @OA\Property(property="name", type="string", description="Название цели."),
     *                 @OA\Property(property="target_amount", type="number", format="float", description="Целевая сумма."),
     *                 @OA\Property(property="current_amount", type="number", format="float", description="Текущая накопленная сумма."),
     *                 @OA\Property(property="target_date", type="string", format="date", description="Целевая дата достижения."),
     *                 @OA\Property(property="description", type="string", description="Описание цели."),
     *                 @OA\Property(property="priority", type="string", description="Приоритет цели."),
     *                 @OA\Property(property="progress", type="number", format="float", description="Прогресс достижения цели в процентах.")
     *             )
     *         )
     *     )
     * )
     */
    public function setFinancialGoal(SetFinancialGoalRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $goal = $this->goalService->createGoal(
            $userId,
            $data['name'],
            $data['target_amount'],
            $data['target_date'],
            $data['current_amount'] ?? 0,
            $data['description'] ?? null,
            $data['priority'] ?? 'medium'
        );

        return response()->json([
            'message' => 'Финансовая цель успешно создана.',
            'goal'    => $goal,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/goals",
     *     summary="Получить финансовые цели",
     *     description="Возвращает финансовые цели пользователя.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="status",
     *         in="query",
     *         required=false,
     *         description="Статус целей (active, completed, all).",
     *         @OA\Schema(type="string", enum={"active", "completed", "all"})
     *     ),
     *     @OA\Parameter(
     *         name="priority",
     *         in="query",
     *         required=false,
     *         description="Приоритет целей (low, medium, high).",
     *         @OA\Schema(type="string", enum={"low", "medium", "high"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список финансовых целей",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="goals",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", description="ID цели."),
     *                     @OA\Property(property="name", type="string", description="Название цели."),
     *                     @OA\Property(property="target_amount", type="number", format="float", description="Целевая сумма."),
     *                     @OA\Property(property="current_amount", type="number", format="float", description="Текущая накопленная сумма."),
     *                     @OA\Property(property="target_date", type="string", format="date", description="Целевая дата достижения."),
     *                     @OA\Property(property="description", type="string", description="Описание цели."),
     *                     @OA\Property(property="priority", type="string", description="Приоритет цели."),
     *                     @OA\Property(property="status", type="string", description="Статус цели (active, completed)."),
     *                     @OA\Property(property="progress", type="number", format="float", description="Прогресс достижения цели в процентах."),
     *                     @OA\Property(property="days_remaining", type="integer", description="Количество дней до целевой даты."),
     *                     @OA\Property(property="amount_needed_per_day", type="number", format="float", description="Необходимая сумма накоплений в день.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getFinancialGoals(GetFinancialGoalsRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $goals = $this->goalService->getGoals(
            $userId,
            $data['status'] ?? 'active',
            $data['priority'] ?? null
        );

        return response()->json([
            'goals' => $goals
        ]);
    }

    /**
     * @OA\Put(
     *     path="/api/finance/goal/{id}/progress",
     *     summary="Обновить прогресс финансовой цели",
     *     description="Обновляет текущую сумму накоплений для финансовой цели.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID финансовой цели.",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"amount"},
     *             @OA\Property(
     *                 property="amount",
     *                 type="number",
     *                 format="float",
     *                 description="Сумма для добавления к текущей."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Прогресс успешно обновлен.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Прогресс цели успешно обновлен."),
     *             @OA\Property(
     *                 property="goal",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", description="ID цели."),
     *                 @OA\Property(property="current_amount", type="number", format="float", description="Текущая накопленная сумма."),
     *                 @OA\Property(property="target_amount", type="number", format="float", description="Целевая сумма."),
     *                 @OA\Property(property="progress", type="number", format="float", description="Прогресс достижения цели в процентах."),
     *                 @OA\Property(property="status", type="string", description="Статус цели (active, completed).")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Цель не найдена.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Финансовая цель не найдена.")
     *         )
     *     )
     * )
     */
    public function updateGoalProgress($id, Request $request): JsonResponse
    {
        $request->validate([
            'amount' => 'required|numeric|min:0',
        ]);

        $userId = auth()->id();
        $goal = $this->goalService->getGoalByIdAndUser($id, $userId);

        if (!$goal) {
            return response()->json(['message' => 'Финансовая цель не найдена.'], HttpStatusCodes::NOT_FOUND);
        }

        $updatedGoal = $this->goalService->updateProgress($id, $request->amount);

        return response()->json([
            'message' => 'Прогресс цели успешно обновлен.',
            'goal'    => $updatedGoal,
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/finance/category",
     *     summary="Создать категорию",
     *     description="Создает новую категорию для финансовых записей.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"name", "type"},
     *             @OA\Property(
     *                 property="name",
     *                 type="string",
     *                 description="Название категории."
     *             ),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"expense", "income", "saving", "investment"},
     *                 description="Тип категории."
     *             ),
     *             @OA\Property(
     *                 property="icon",
     *                 type="string",
     *                 description="Иконка категории (опционально)."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Категория успешно создана.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Категория успешно создана."),
     *             @OA\Property(
     *                 property="category",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", description="ID категории."),
     *                 @OA\Property(property="name", type="string", description="Название категории."),
     *                 @OA\Property(property="type", type="string", description="Тип категории."),
     *                 @OA\Property(property="icon", type="string", description="Иконка категории.")
     *             )
     *         )
     *     )
     * )
     */
    public function createCategory(CreateCategoryRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $category = $this->categoryService->create(
            $userId,
            $data['name'],
            $data['type'],
            $data['icon'] ?? null
        );

        return response()->json([
            'message'  => 'Категория успешно создана.',
            'category' => $category,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/categories",
     *     summary="Получить категории",
     *     description="Возвращает список категорий пользователя с возможностью фильтрации по типу.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="type",
     *         in="query",
     *         required=false,
     *         description="Тип категорий (expense, income, saving, investment).",
     *         @OA\Schema(type="string", enum={"expense", "income", "saving", "investment"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Список категорий",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="categories",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", description="ID категории."),
     *                     @OA\Property(property="name", type="string", description="Название категории."),
     *                     @OA\Property(property="type", type="string", description="Тип категории."),
     *                     @OA\Property(property="icon", type="string", description="Иконка категории."),
     *                     @OA\Property(property="color", type="string", description="Цвет категории.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getCategories(Request $request): JsonResponse
    {
        $type = $request->query('type');
        $userId = auth()->id();

        $categories = $this->categoryService->getByUserAndType(
            $userId,
            $type
        );

        return response()->json([
            'categories' => $categories
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/finance/export",
     *     summary="Экспортировать финансовые данные",
     *     description="Экспортирует финансовые данные в выбранном формате.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"format", "period"},
     *             @OA\Property(
     *                 property="format",
     *                 type="string",
     *                 enum={"csv", "pdf", "excel"},
     *                 description="Формат экспорта."
     *             ),
     *             @OA\Property(
     *                 property="period",
     *                 type="string",
     *                 enum={"week", "month", "year", "custom"},
     *                 description="Период для экспорта."
     *             ),
     *             @OA\Property(
     *                 property="start_date",
     *                 type="string",
     *                 format="date",
     *                 description="Начальная дата для периода custom (YYYY-MM-DD)."
     *             ),
     *             @OA\Property(
     *                 property="end_date",
     *                 type="string",
     *                 format="date",
     *                 description="Конечная дата для периода custom (YYYY-MM-DD)."
     *             ),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"expense", "income", "saving", "investment", "all"},
     *                 description="Тип записей для экспорта."
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные успешно экспортированы.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Данные успешно экспортированы."),
     *             @OA\Property(property="file_url", type="string", description="URL для скачивания файла.")
     *         )
     *     )
     * )
     */
    public function exportFinanceData(ExportFinanceDataRequest $request): JsonResponse
    {
        $data = $request->validated();
        $userId = auth()->id();

        $fileUrl = $this->exportService->export(
            $userId,
            $data['format'],
            $data['period'],
            $data['start_date'] ?? null,
            $data['end_date'] ?? null,
            $data['type'] ?? 'all'
        );

        return response()->json([
            'message'  => 'Данные успешно экспортированы.',
            'file_url' => $fileUrl,
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/finance/import",
     *     summary="Импортировать финансовые данные",
     *     description="Импортирует финансовые данные из файла CSV, Excel.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 type="object",
     *                 required={"file"},
     *                 @OA\Property(
     *                     property="file",
     *                     type="string",
     *                     format="binary",
     *                     description="Файл с данными."
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные успешно импортированы.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Данные успешно импортированы."),
     *             @OA\Property(property="imported_count", type="integer", description="Количество импортированных записей.")
     *         )
     *     )
     * )
     */
    public function importFinanceData(ImportFinanceDataRequest $request): JsonResponse
    {
        $file = $request->file('file');
        $userId = auth()->id();

        $importedCount = $this->importService->import($userId, $file);

        return response()->json([
            'message'        => 'Данные успешно импортированы.',
            'imported_count' => $importedCount,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/finance/advice",
     *     summary="Получить финансовые советы",
     *     description="Возвращает персонализированные финансовые советы на основе финансовой активности пользователя.",
     *     tags={"Finance"},
     *     security={{"sanctum": {}}},
     *     @OA\Response(
     *         response=200,
     *         description="Список финансовых советов",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="advice",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="title", type="string", description="Заголовок совета."),
     *                     @OA\Property(property="description", type="string", description="Описание совета."),
     *                     @OA\Property(property="type", type="string", description="Тип совета (saving, expense, income, investment).")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getFinancialAdvice(): JsonResponse
    {
        $userId = auth()->id();
        $advice = $this->adviceService->getPersonalizedAdvice($userId);

        return response()->json([
            'advice' => $advice
        ]);
    }
}
