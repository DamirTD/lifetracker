<?php

namespace App\Modules\Auth\ServiceInterfaces;

interface AuthServiceInterface
{
    public function register(array $data): array;
    public function login(string $login, string $password): array;
    public function logout(): void;
}
