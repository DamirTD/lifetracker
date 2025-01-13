<?php

namespace App\Modules\Auth\Services;

use App\Models\User;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use App\Modules\Auth\Repository\UserRepository;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthService implements AuthServiceInterface
{
    public function __construct(
        protected UserRepository $userRepository,
        protected UserQueryInterface $userQuery
    ) {
    }

    public function register(array $data): User
    {
        $user = new User([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password'])
        ]);

        $this->userRepository->save($user);

        $user->createToken('auth_token')->plainTextToken;

        return $user;
    }

    public function login(string $login, string $password): array
    {
        $user = $this->userQuery->findByLogin($login);

        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user'  => $user,
            'token' => $token,
        ];
    }

    public function logout(): void
    {
        $user = Auth::user();

        if ($user instanceof User) {
            $user->tokens()->delete();
        } else {
            abort(404, 'No user found.');
        }
    }
}
