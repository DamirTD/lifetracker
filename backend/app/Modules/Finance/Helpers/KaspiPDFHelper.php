<?php

namespace App\Modules\Finance\Helpers;

use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use Exception;
use Illuminate\Http\UploadedFile;
use Smalot\PdfParser\Parser;

class KaspiPDFHelper
{
    /**
     * @throws Exception
     */
    public function processPdfTransactions(
        UploadedFile             $file,
        KaspiPDFServiceInterface $transactionService,
        ?string                  $sortBy,
        string                   $sortOrder
    ): array {
        $pdfText = (new Parser())->parseFile($file->getPathname())->getText();

        $transactions = array_filter(array_map(
            fn($line) => $transactionService->processLine($line),
            explode("\n", $pdfText)
        ));

        return $transactionService->sort($transactions, $sortBy, $sortOrder);
    }

    public function calculateSummary(array $transactions): array
    {
        $totals = ['spent' => 0, 'received' => 0];
        $dates  = [];

        foreach ($transactions as $transaction) {
            $dates[] = $transaction['date'];
            $amount  = (float)$transaction['amount'];

            match ($transaction['operation']) {
                'Перевод', 'Покупка' => $totals['spent'] += $amount,
                'Пополнение'         => $totals['received'] += $amount,
                default              => null,
            };
        }

        return [
            'total_spent'    => number_format($totals['spent'], 2, '.', ''),
            'total_received' => number_format($totals['received'], 2, '.', ''),
            'period'         => sprintf('%s - %s', min($dates), max($dates)),
        ];
    }
}
