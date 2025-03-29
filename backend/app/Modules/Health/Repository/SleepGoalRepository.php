<?php

namespace App\Modules\Health\Repository;

use App\Models\SleepGoal;
use App\Modules\Health\RepositoryInterfaces\SleepGoalRepositoryInterface;

class SleepGoalRepository implements SleepGoalRepositoryInterface
{
    public function create(array $data): array
    {
        return SleepGoal::create($data)->toArray();
    }
    public function findById(int $id): ?array
    {
        $goal = SleepGoal::find($id);
        return $goal ? $goal->toArray() : null;
    }
    public function update(int $id, array $data): array
    {
        $goal = SleepGoal::findOrFail($id);
        $goal->update($data);
        return $goal->fresh()->toArray();
    }
    public function delete(int $id): bool
    {
        return SleepGoal::destroy($id) > 0;
    }
    public function getGoalsForUser(int $userId): ?array
    {
        $goal = SleepGoal::where('user_id', $userId)->first();
        return $goal ? $goal->toArray() : null;
    }
}
