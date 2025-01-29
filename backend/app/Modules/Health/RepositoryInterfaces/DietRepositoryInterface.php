<?php

namespace App\Modules\Health\RepositoryInterfaces;

use App\Models\DietEntry;

interface DietRepositoryInterface
{
    public function createDietEntry(array $data): DietEntry;
    public function getDietEntriesByUserId(int $userId, string $date);
}
