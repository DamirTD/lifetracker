<?php

namespace App\Modules\Auth\ServiceInterfaces;

use App\Models\User;

interface AuthServiceInterface
{
    public function register(array $data): User;
    public function login(string $login, string $password): array;
    public function logout(): void;
}
