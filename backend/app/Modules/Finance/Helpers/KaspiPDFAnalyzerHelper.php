<?php

namespace App\Modules\Finance\Helpers;

class KaspiPDFAnalyzerHelper
{
    public function formatData(?string $details, float $amount): array
    {
        return [
            'details' => $details,
            'amount'  => $amount,
        ];
    }

    public function getMaxFromCountArray(array $counts, array $sums): array
    {
        $maxDetail = '';
        $maxAmount = 0;
        $maxCount  = 0;

        foreach ($counts as $detail => $count) {
            if ($count > $maxCount) {
                $maxCount  = $count;
                $maxAmount = $sums[$detail];
                $maxDetail = $detail;
            }
        }

        return [
            'details' => $maxDetail,
            'amount'  => $maxAmount,
            'count'   => $maxCount,
        ];
    }

    public function formatResult(array $counts, array $sums, array $maxOperations): array
    {
        return [
            'most_spent'          => $this->formatData($maxOperations['mostSpent'], $maxOperations['mostSpentAmount']),
            'most_transferred'    => $this->formatData($maxOperations['mostTransferred'], $maxOperations['mostTransferredAmount']),
            'most_received'       => $this->formatData($maxOperations['mostReceived'], $maxOperations['mostReceivedAmount']),
            'most_transferred_to' => $this->getMaxFromCountArray($counts['Перевод'], $sums['Перевод']),
            'most_spent_at'       => $this->getMaxFromCountArray($counts['Покупка'], $sums['Покупка']),
            'most_received_from'  => $this->getMaxFromCountArray($counts['Пополнение'], $sums['Пополнение']),
        ];
    }

    public function initializeOperationArrays(): array
    {
        return [
            'Перевод'    => [],
            'Покупка'    => [],
            'Пополнение' => [],
        ];
    }

    public function initializeMaxOperations(): array
    {
        return [
            'mostSpent'             => null,
            'mostSpentAmount'       => 0.0,
            'mostTransferred'       => null,
            'mostTransferredAmount' => 0.0,
            'mostReceived'          => null,
            'mostReceivedAmount'    => 0.0,
        ];
    }

    public function processTransaction(string $operation, ?string $details, float $amount, array &$counts, array &$sums): void
    {
        if (!isset($counts[$operation][$details])) {
            $counts[$operation][$details] = 0;
            $sums[$operation][$details]   = 0.0;
        }

        $counts[$operation][$details]++;
        $sums[$operation][$details] += $amount;
    }

    public function updateMaxAmounts(string $operation, float $amount, ?string $details, array &$maxOperations): void
    {
        if ($operation === 'Перевод' && $amount > $maxOperations['mostTransferredAmount']) {
            $maxOperations['mostTransferredAmount'] = $amount;
            $maxOperations['mostTransferred']       = $details;
        }

        if ($operation === 'Покупка' && $amount > $maxOperations['mostSpentAmount']) {
            $maxOperations['mostSpentAmount'] = $amount;
            $maxOperations['mostSpent']       = $details;
        }

        if ($operation === 'Пополнение' && $amount > $maxOperations['mostReceivedAmount']) {
            $maxOperations['mostReceivedAmount'] = $amount;
            $maxOperations['mostReceived']       = $details;
        }
    }
}
