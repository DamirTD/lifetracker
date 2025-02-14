<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

class UserController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/user",
     *     summary="Получить данные пользователя",
     *     tags={"Auth"},
     *     security={{"sanctum": {}}},
     *     @OA\Response(response=200, description="Успешно")
     * )
     */
    public function getUser(): JsonResponse
    {
        return response()->json(auth()->user());
    }
}
