<?php

namespace App\Http\Controllers;

use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\JsonResponse;

abstract class Controller
{
    protected array $validatedData;

    protected function jsonResponse(array $data, int $statusCode = HttpStatusCodes::OK): JsonResponse
    {
        return response()->json($data, $statusCode);
    }

    protected function wrap($request, callable $callback): JsonResponse
    {
        if ($request instanceof FormRequest) {
            $this->validatedData = $request->validated();
        } else {
            $this->validatedData = $request->all();
        }

        try {
            $result = $callback($this->validatedData);

            return $this->jsonResponse([
                'success' => true,
                'error'   => null,
                'data'    => $result,
            ]);

        } catch (\Exception $e) {
            $statusCode = $e->getCode();
            if (!is_numeric($statusCode) || $statusCode < 100 || $statusCode > 599) {
                $statusCode = HttpStatusCodes::INTERNAL_SERVER_ERROR;
            }
            return $this->jsonResponse([
                'success' => false,
                'error'   => $e->getMessage(),
            ], (int)$statusCode);
        }
    }

}
