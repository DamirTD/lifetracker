<?php

namespace App\Modules\Finance\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Finance\Helpers\KaspiPDFHelper;
use App\Modules\Finance\Requests\KaspiPDFAnalyzeRequest;
use App\Modules\Finance\Requests\KaspiPdfRequest;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFAnalyzerServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use Exception;
use Illuminate\Http\JsonResponse;

class KaspiBankController extends Controller
{
    public function __construct(
        protected KaspiPDFServiceInterface            $kaspiService,
        protected KaspiPDFHelper                      $kaspiHelper,
        protected KaspiPDFAnalyzerServiceInterface    $kaspiAnalyzerService
    ) {
    }

    /**
     *
     * @OA\Post(
     *     path="/api/import-pdf",
     *     summary="Импорт PDF с транзакциями",
     *     description="Загружает PDF-файл с транзакциями, сортирует данные и возвращает их вместе с итоговым резюме.",
     *     tags={"Finance"},
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
     *                     description="PDF-файл с транзакциями."
     *                 ),
     *                 @OA\Property(
     *                     property="sortBy",
     *                     type="string",
     *                     enum={"date", "amount", "operation"},
     *                     description="Поле для сортировки транзакций."
     *                 ),
     *                 @OA\Property(
     *                     property="sortOrder",
     *                     type="string",
     *                     enum={"asc", "desc"},
     *                     default="desc",
     *                     description="Порядок сортировки (по умолчанию - по убыванию)."
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Успешный импорт.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="summary",
     *                 type="object",
     *                 @OA\Property(property="total_spent", type="string", example="1234.56"),
     *                 @OA\Property(property="total_received", type="string", example="789.01"),
     *                 @OA\Property(property="period", type="string", example="2024-01-01 - 2024-12-31")
     *             ),
     *             @OA\Property(
     *                 property="transactions",
     *                 type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="date", type="string", example="2024-01-01"),
     *                     @OA\Property(property="amount", type="string", example="500.00"),
     *                     @OA\Property(property="operation", type="string", example="Перевод")
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="The given data was invalid."),
     *             @OA\Property(
     *                 property="errors",
     *                 type="object",
     *                 additionalProperties=@OA\Property(type="array", @OA\Items(type="string"))
     *             )
     *         )
     *     )
     * )
     * @throws Exception
     */
    public function importPdf(KaspiPdfRequest $request): JsonResponse
    {
        $file      = $request->file('file');
        $sortBy    = $request->getSortBy();
        $sortOrder = $request->getSortOrder();

        $transactions = $this->kaspiHelper->processPdfTransactions($file, $this->kaspiService, $sortBy, $sortOrder);
        $summary      = $this->kaspiHelper->calculateSummary($transactions);

        return response()->json([
            'summary'      => $summary,
            'transactions' => array_values($transactions),
        ]);
    }

    /**
     *
     * @OA\Post(
     *     path="/api/analyze",
     *     summary="Анализ транзакций",
     *     description="Выполняет анализ переданного массива транзакций.",
     *     tags={"Finance"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"transactions"},
     *             @OA\Property(
     *                 property="transactions",
     *                 type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="date", type="string", example="2024-01-01"),
     *                     @OA\Property(property="operation", type="string", example="Перевод"),
     *                     @OA\Property(property="amount", type="number", example=500.00),
     *                     @OA\Property(property="details", type="string", example="Описание операции")
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Успешный анализ транзакций.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="most_common_operation", type="string", example="Перевод"),
     *             @OA\Property(property="highest_transaction", type="object",
     *                 @OA\Property(property="date", type="string", example="2024-01-01"),
     *                 @OA\Property(property="amount", type="number", example=1500.00),
     *                 @OA\Property(property="operation", type="string", example="Пополнение")
     *             ),
     *             @OA\Property(property="total_transactions", type="integer", example=3)
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="The given data was invalid."),
     *             @OA\Property(
     *                 property="errors",
     *                 type="object",
     *                 additionalProperties=@OA\Property(type="array", @OA\Items(type="string"))
     *             )
     *         )
     *     )
     * )
     */
    public function analyze(KaspiPDFAnalyzeRequest $request): JsonResponse
    {
        $transactions = $request->transactions();

        $result = $this->kaspiAnalyzerService->analyze($transactions);

        return response()->json($result);
    }
}
