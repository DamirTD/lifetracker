<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

class LogoutController extends Controller
{
    public function __construct(
        protected AuthServiceInterface $authService
    ) {
    }

    /**
     * @OA\Post(
     *     path="/api/auth/logout",
     *     summary="Выход пользователя",
     *     tags={"Auth"},
     *     @OA\Response(
     *         response=200,
     *         description="Успешный выход",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Successfully logged out.")
     *         )
     *     )
     * )
     */
    public function logout(): JsonResponse
    {
        return $this->wrap(request(), function () {
            $this->authService->logout();
        });
    }
}
