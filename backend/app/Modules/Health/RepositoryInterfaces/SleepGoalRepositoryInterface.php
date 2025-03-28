<?php

namespace App\Modules\Health\RepositoryInterfaces;

interface SleepGoalRepositoryInterface
{
    public function create(array $data): array;
    public function findById(int $id): ?array;
    public function update(int $id, array $data): array;
    public function delete(int $id): bool;
    public function getGoalsForUser(int $userId): ?array;
}
