<?php

namespace App\Modules\Health\Repository;

use App\Models\DietEntry;
use App\Modules\Health\RepositoryInterfaces\DietRepositoryInterface;

class DietRepository implements DietRepositoryInterface
{
    public function createDietEntry(array $data): DietEntry
    {
        return DietEntry::create($data);
    }

    public function getDietEntriesByUserId(int $userId, string $date)
    {
        return DietEntry::where('user_id', $userId)->where('date', $date)->get();
    }
}
