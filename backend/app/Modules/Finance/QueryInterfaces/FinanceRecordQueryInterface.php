<?php

namespace App\Modules\Finance\QueryInterfaces;

interface FinanceRecordQueryInterface
{
    public function getByUserAndPeriod(int $userId, string $period);
    public function store(array $data);
}
