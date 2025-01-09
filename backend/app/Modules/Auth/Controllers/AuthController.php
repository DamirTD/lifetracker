<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Auth\Requests\LoginRequest;
use App\Modules\Auth\Requests\RegisterRequest;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    public function __construct(
        protected AuthServiceInterface $authService
    ) {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        return $this->wrap($request, function ($validatedData) {

            $user = $this->authService->register($validatedData);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'user'  => $user,
                'token' => $token,
            ]);
        });
    }

    public function login(LoginRequest $request): JsonResponse
    {
        return $this->wrap($request, function ($validatedData) {
            return $this->authService->login(
                $validatedData['login'], $validatedData['password']
            );
        });
    }

    public function logout(): JsonResponse
    {
        return $this->wrap(request(), function () {

            $this->authService->logout();

            return response()->json(['message' => 'Successfully logged out.']);
        });
    }
}
