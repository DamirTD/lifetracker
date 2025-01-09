<?php

namespace App\Modules\Auth\Repository;

use App\Models\User;
use App\Modules\Auth\RepositoryInterface\UserRepositoryInterface;

class UserRepository implements UserRepositoryInterface
{
    public function save(User $user): void
    {
        $user->save();
    }
}
