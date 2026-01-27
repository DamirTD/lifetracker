<?php

namespace App\Modules\Finance\Query;

use App\Models\FinanceRecord;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class FinanceRecordQuery implements FinanceRecordQueryInterface
{
    /**
     * @param int $userId
     * @param string|null $period
     * @return Collection
     */
    public function getByUserAndPeriod(int $userId, ?string $period): Collection
    {
        $query = FinanceRecord::where('user_id', $userId);

        if ($period) {
            $query->where('period', $period);
        }

        return $query->get();
    }

    /**
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
    ): LengthAwarePaginator
    {
        $query = FinanceRecord::where('user_id', $userId);

        if ($period) {
            $query->where('period', $period);
        }

        if ($type) {
            $query->where('type', $type);
        }

        if ($categoryId) {
            $query->where('category_id', $categoryId);
        }

        if ($startDate && $endDate) {
            $query->whereBetween('date', [$startDate, $endDate]);
        } else if ($startDate) {
            $query->where('date', '>=', $startDate);
        } else if ($endDate) {
            $query->where('date', '<=', $endDate);
        }

        $query->with('category');

        $query->orderBy($sortBy, $sortDirection);

        return $query->paginate($perPage, ['*'], 'page', $page)
            ->through(function (FinanceRecord $record) {
                return [
                    'id' => $record->id,
                    'amount' => $record->amount,
                    'type' => $record->type,
                    'period' => $record->period,
                    'category_id' => $record->category_id,
                    'category_name' => $record->category?->name,
                    'date' => $record->date->toIso8601String(),
                    'description' => $record->description,
                    'is_recurring' => $record->is_recurring,
                    'recurring_frequency' => $record->recurring_frequency,
                ];
            });
    }

    /**
     * @param array $data
     * @return FinanceRecord
     */
    public function store(array $data): FinanceRecord
    {
        if (!isset($data['date'])) {
            $data['date'] = now();
        }

        // Поле period больше не используется, но оставляем null для совместимости
        if (!isset($data['period'])) {
            $data['period'] = null;
        }

        $data['user_id'] = auth()->id();

        $record = FinanceRecord::create($data);
        $record->load('category');
        return $record;

    }

    /**
     * @param int $id
     * @param int $userId
     * @return FinanceRecord|null
     */
    public function findByIdAndUser(int $id, int $userId): ?FinanceRecord
    {
        return FinanceRecord::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    /**
     * @param int $id
     * @param array $data
     * @return FinanceRecord
     */
    public function update(int $id, array $data): FinanceRecord
    {
        $record = FinanceRecord::findOrFail($id);
        $record->update($data);

        return $record;
    }

    /**
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool
    {
        $record = FinanceRecord::findOrFail($id);
        return $record->delete();
    }
}
