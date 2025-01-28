<?php

namespace App\Modules\Health\Repository;

use App\Models\Sleep;
use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;

class SleepRepository implements SleepRepositoryInterface
{
    public function create(array $data): array
    {
        return Sleep::create($data)->toArray();
    }
}
