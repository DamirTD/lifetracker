<?php

namespace App\Modules\Finance\ServiceInterfaces;

interface FinanceStatisticsServiceInterface
{
    /**
     *
     * @param int $userId
     * @param string|null $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @return array
     */
    public function getSummary(int $userId, ?string $period, ?string $startDate, ?string $endDate): array;

    /**
     *
     * @param int $userId
     * @param string $period
     * @param string|null $type
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $groupBy
     * @return array
     */
    public function getStatistics(
        int $userId,
        string $period,
        ?string $type,
        ?string $startDate,
        ?string $endDate,
        string $groupBy
    ): array;
}
