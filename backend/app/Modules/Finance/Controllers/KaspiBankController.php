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

    public function analyze(KaspiPDFAnalyzeRequest $request): JsonResponse
    {
        $transactions = $request->transactions();

        $result = $this->kaspiAnalyzerService->analyze($transactions);

        return response()->json($result);
    }
}
