<?php

namespace App\Modules\Finance\Repository;

use App\Models\FinanceRecord;
use App\Modules\Finance\RepositoryInterfaces\FinanceRecordRepositoryInterface;

class FinanceRecordRepository implements FinanceRecordRepositoryInterface
{
    public function create(array $data): FinanceRecord
    {
        return FinanceRecord::create($data);
    }
}
