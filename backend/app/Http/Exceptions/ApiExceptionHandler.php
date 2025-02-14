<?php

namespace App\Http\Exceptions;

use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use Exception;

class ApiExceptionHandler
{
    /**
     *
     * @param callable $callback
     * @return JsonResponse
     */
    public static function handle(callable $callback): JsonResponse
    {
        try {
            return $callback();
        } catch (Exception $e) {
            $statusCode = self::getStatusCode($e);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $statusCode);
        }
    }

    /**
     *
     * @param Exception $e
     * @return int
     */
    private static function getStatusCode(Exception $e): int
    {
        $statusCode = $e->getCode();
        if (!is_numeric($statusCode) || $statusCode < 100 || $statusCode > 599) {
            return HttpStatusCodes::INTERNAL_SERVER_ERROR;
        }
        return (int)$statusCode;
    }
}
