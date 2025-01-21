<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\Helpers\KaspiPDFAnalyzerHelper;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFAnalyzerServiceInterface;
use App\Utils\Enums\KaspiOperationEnums;

class KaspiPDFAnalyzerService implements KaspiPDFAnalyzerServiceInterface
{
    public function __construct(
        protected KaspiPDFAnalyzerHelper $transactionAnalyzerHelper
    ) {
    }

    public function analyze(array $transactions): array
    {
        $counts        = $this->transactionAnalyzerHelper->initializeOperationArrays();
        $sums          = $this->transactionAnalyzerHelper->initializeOperationArrays();
        $maxOperations = $this->transactionAnalyzerHelper->initializeMaxOperations();

        foreach ($transactions as $transaction) {
            $operation = $transaction['operation'];
            $amount    = (float) $transaction['amount'];
            $details   = $transaction['details'];

            if (KaspiOperationEnums::tryFrom($operation)) {
                $this->transactionAnalyzerHelper->processTransaction($operation, $details, $amount, $counts, $sums);
            }
            $this->transactionAnalyzerHelper->updateMaxAmounts($operation, $amount, $details, $maxOperations);
        }
        return $this->transactionAnalyzerHelper->formatResult($counts, $sums, $maxOperations);
    }
}
