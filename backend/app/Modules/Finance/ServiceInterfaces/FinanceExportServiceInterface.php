<?php

namespace App\Modules\Finance\ServiceInterfaces;

interface FinanceExportServiceInterface
{
    /**
     * @param int $userId
     * @param string $format
     * @param string $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $type
     * @return string File URL
     */
    public function export(
        int $userId,
        string $format,
        string $period,
        ?string $startDate,
        ?string $endDate,
        string $type
    ): string;
}
