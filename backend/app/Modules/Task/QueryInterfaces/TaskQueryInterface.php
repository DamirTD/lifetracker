<?php

namespace App\Modules\Task\QueryInterfaces;

use Illuminate\Pagination\LengthAwarePaginator;

interface TaskQueryInterface
{
    public function getAllTasks($userId): LengthAwarePaginator;
}
