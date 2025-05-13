<?php

namespace App\Modules\Auth\Services;

use App\Models\User;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use App\Modules\Auth\Repository\UserRepository;
use App\Modules\Auth\RepositoryInterface\UserRepositoryInterface;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use App\Utils\Constants\HttpStatusCodes;
use Exception;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthService implements AuthServiceInterface
{
    public function __construct(
        protected UserRepositoryInterface $userRepository,
        protected UserQueryInterface $userQuery
    ) {
    }

    public function register(array $data): array
    {
        $user = new User([
            'name'     => $data['name'],
            'surname'  => $data['surname'],
            'login'    => $data['login'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password'])
        ]);

        $this->userRepository->save($user);

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user'  => $user,
            'token' => $token,
        ];
    }

    /**
     * @throws Exception
     */
    public function login(string $login, string $password): array
    {
        $user = $this->userQuery->findByLogin($login);

        if (!$user) {
            throw new \Exception('Пользователь с таким логином не найден.');
        }

        if (!Hash::check($password, $user->password)) {
            throw new \Exception('Неверный пароль.');
        }

        $user->tokens()->where('name', 'auth_token')->delete();

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
            abort(HttpStatusCodes::NOT_FOUND, 'No user found.');
        }
    }
}
