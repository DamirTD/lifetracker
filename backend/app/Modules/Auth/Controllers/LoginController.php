<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Auth\Requests\LoginRequest;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

class LoginController extends Controller
{
    public function __construct(
        protected AuthServiceInterface $authService
    ) {
    }

    /**
     * @OA\Post(
     *     path="/api/auth/login",
     *     summary="Вход пользователя",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/LoginRequest")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Успешный вход",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(property="token", type="string")
     *         )
     *     )
     * )
     */
    public function login(LoginRequest $request): JsonResponse
    {
        return $this->wrap($request, function ($validatedData) {
            return $this->authService->login(
                $validatedData['login'],
                $validatedData['password']
            );
        });
    }
}
