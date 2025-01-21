<?php

namespace App\Modules\Finance\ServiceInterfaces;

use App\Modules\Finance\DTO\KaspiPDFTransactionDTO;

interface KaspiPDFServiceInterface
{
    public function getOperation(string $line): ?string;
    public function getAmount(string $line): ?string;
    public function extractDetails(string $line): string;
    public function createTransaction(?string $date, ?string $operation, ?string $amount, string $details): ?KaspiPDFTransactionDTO;
    public function sort(array $transactions, ?string $sortBy, string $sortOrder = 'desc'): array;
    public function processLine(string $line): ?array;
}
