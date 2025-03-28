<?php

namespace App\Modules\Health\Repository;

use App\Models\Sleep;
use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;
use Carbon\Carbon;

class SleepRepository implements SleepRepositoryInterface
{
    public function create(array $data): array
    {
        return Sleep::create($data)->toArray();
    }

    public function findById(int $id): ?array
    {
        $sleep = Sleep::find($id);
        return $sleep ? $sleep->toArray() : null;
    }

    public function update(int $id, array $data): array
    {
        $sleep = Sleep::findOrFail($id);
        $sleep->update($data);
        return $sleep->fresh()->toArray();
    }

    public function delete(int $id): bool
    {
        return Sleep::destroy($id) > 0;
    }


    public function getAllForUser(int $userId): array
    {
        return Sleep::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get()
            ->toArray();
    }

    public function getSleepDataForPeriod(int $userId, Carbon $startDate): array
    {
        return Sleep::where('user_id', $userId)
            ->where('created_at', '>=', $startDate)
            ->orderBy('created_at', 'desc')
            ->get()
            ->toArray();
    }

    public function getRecentSleepData(int $userId, int $limit): array
    {
        return Sleep::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get()
            ->toArray();
    }
}
