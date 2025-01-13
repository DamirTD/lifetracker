<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Auth\Requests\LoginRequest;
use App\Modules\Auth\Requests\RegisterRequest;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

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

            return response()->json([
                'user'  => $user
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
        $user = Auth::user();

        return $user->update(['token' => null]);

    }

}
