<?php

namespace App\Modules\Auth\QueryInterface;

use App\Models\User;

interface UserQueryInterface
{
    public function findByLogin(string $login): ?User;
}
