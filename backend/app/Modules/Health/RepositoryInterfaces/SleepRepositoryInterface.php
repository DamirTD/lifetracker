<?php

namespace App\Modules\Health\RepositoryInterfaces;

interface SleepRepositoryInterface{
    public function create(array $data): array;
}
