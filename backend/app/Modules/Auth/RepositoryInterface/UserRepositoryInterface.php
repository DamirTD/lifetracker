<?php

namespace App\Modules\Auth\RepositoryInterface;
use App\Models\User;
interface UserRepositoryInterface
{
    public function save(User $user);
}
