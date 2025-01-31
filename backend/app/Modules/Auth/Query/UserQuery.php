<?php

namespace App\Modules\Auth\Query;

use App\Models\User;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use Illuminate\Database\Eloquent\Builder;

class UserQuery implements UserQueryInterface
{
    public function findByLogin(string $login): ?User
    {
        return User::where('login', $login)->first();
    }
}
