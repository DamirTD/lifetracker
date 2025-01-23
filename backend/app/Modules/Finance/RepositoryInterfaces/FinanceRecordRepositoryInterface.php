<?php

namespace App\Modules\Finance\RepositoryInterfaces;

use App\Models\FinanceRecord;

interface FinanceRecordRepositoryInterface
{
    public function create(array $data): FinanceRecord;
}
