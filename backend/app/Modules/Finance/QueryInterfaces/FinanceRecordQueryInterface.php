<?php

namespace App\Modules\Finance\QueryInterfaces;

use App\Models\FinanceRecord;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface FinanceRecordQueryInterface
{
    /**
     *
     * @param int $userId
     * @param string|null $period
     * @return Collection
     */
    public function getByUserAndPeriod(int $userId, ?string $period): Collection;

    /**
     *
     * @param int $userId
     * @param string|null $period
     * @param string|null $type
     * @param int|null $categoryId
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $sortBy
     * @param string $sortDirection
     * @param int $page
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getFilteredRecords(
        int $userId,
        ?string $period,
        ?string $type,
        ?int $categoryId,
        ?string $startDate,
        ?string $endDate,
        string $sortBy,
        string $sortDirection,
        int $page,
        int $perPage
    ): LengthAwarePaginator;

    /**
     *
     * @param array $data
     * @return FinanceRecord
     */
    public function store(array $data): FinanceRecord;

    /**
     *
     * @param int $id
     * @param int $userId
     * @return FinanceRecord|null
     */
    public function findByIdAndUser(int $id, int $userId): ?FinanceRecord;

    /**
     *
     * @param int $id
     * @param array $data
     * @return FinanceRecord
     */
    public function update(int $id, array $data): FinanceRecord;

    /**
     *
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool;
}
