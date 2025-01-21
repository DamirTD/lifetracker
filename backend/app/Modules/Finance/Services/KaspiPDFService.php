<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\DTO\KaspiPDFTransactionDTO;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use App\Utils\Constants\FinanceConstants;
use App\Utils\Enums\KaspiOperationEnums;
use App\Utils\Sort\KaspiPDFSorter;

class KaspiPDFService implements KaspiPDFServiceInterface
{
    public function getOperation(string $line): ?string
    {
        foreach (KaspiOperationEnums::cases() as $operation) {
            if (str_contains($line, $operation->value)) {
                return $operation->value;
            }
        }
        return null;
    }

    public function getAmount(string $line): ?string
    {
        if (preg_match('/\d[\d\s]*[,\s]*\d{2}/', $line, $matches)) {
            $amount = str_replace([' ', ','], ['', '.'], $matches[0]);
            return number_format((float)$amount, 2, '.', '');
        }
        return null;
    }

    public function extractDetails(string $line): string
    {
        $pattern = '/(?:Перевод|Пополнение|Покупка)\s+(.+)$/u';
        if (preg_match($pattern, $line, $matches)) {
            return trim($matches[1]);
        }
        return '';
    }

    public function createTransaction(?string $date, ?string $operation, ?string $amount, string $details): ?KaspiPDFTransactionDTO
    {
        if(!isset($operation) || !isset($amount)){
            return null;
        }
        return new KaspiPDFTransactionDTO($date, $operation, $amount, $details);
    }

    public function sort(array $transactions, ?string $sortBy, string $sortOrder = 'desc'): array
    {
        if (isset($sortBy)) {
            return KaspiPDFSorter::sort($transactions, $sortBy, $sortOrder);
        }
        return $transactions;
    }

    public function processLine(string $line): ?array
    {
        if (preg_match(FinanceConstants::DATE_PATTERN, $line, $dateMatches)) {
            $date        = $dateMatches[0];
            $operation   = $this->getOperation($line);
            $amount      = $this->getAmount($line);
            $details     = $this->extractDetails($line);
            $transaction = $this->createTransaction($date, $operation, $amount, $details);

            return $transaction?->toArray();
        }
        return null;
    }
}
