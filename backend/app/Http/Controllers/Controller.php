<?php

namespace App\Http\Controllers;

use App\Http\Exceptions\ApiExceptionHandler;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

/**
 * @OA\Info(
 *     title="Swagger API",
 *     version="1.0.0"
 * )
 */
abstract class Controller
{
    protected array $validatedData;

    protected function jsonResponse(array $data, int $statusCode = HttpStatusCodes::OK): JsonResponse
    {
        return response()->json($data, $statusCode);
    }

    protected function wrap($request, callable $callback): JsonResponse
    {
        $this->validatedData = $this->getValidatedData($request);

        return ApiExceptionHandler::handle(function () use ($callback) {
            $result = $callback($this->validatedData);
            return $this->jsonResponse($result);
        });
    }

    private function getValidatedData($request): array
    {
        if ($request instanceof FormRequest) {
            return $request->validated();
        }

        return $request->all();
    }
}
