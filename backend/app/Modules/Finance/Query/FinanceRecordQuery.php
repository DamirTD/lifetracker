<?php

namespace App\Modules\Finance\Query;

use App\Models\FinanceRecord;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;

class FinanceRecordQuery implements FinanceRecordQueryInterface
{
    public function getByUserAndPeriod(int $userId, string $period)
    {
        return FinanceRecord::where('user_id', $userId)
            ->where('period', $period)
            ->get();
    }

    public function store(array $data)
    {
        return FinanceRecord::create([
            'user_id'     => auth()->id(),
            'amount'      => $data['amount'],
            'type'        => $data['type'],
            'period'      => $data['period'],
            'description' => $data['description'],
        ]);
    }
}
