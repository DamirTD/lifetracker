<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\Requests\SetDailyGoalRequest;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use Illuminate\Http\JsonResponse;

class WaterController extends Controller
{

    public function __construct(
        protected WaterServiceInterface $waterService
    ){
    }

    public function setDailyGoal(SetDailyGoalRequest $request): JsonResponse
    {
        return $this->wrap($request, function () use ($request) {
            $dto = new WaterGoalDTO(
                $request->input('weight'),
                $request->input('height'),
                $request->input('goal'),
                $request->input('glass_volume_ml')
            );

            $result = $this->waterService->calculateDailyGoal($dto);

            return [
                'message' => 'Дневная норма рассчитана и установлена.',
                'data'    => $result,
            ];
        });
    }

    public function addGlass(): JsonResponse
    {
        $userId = auth()->id();

        $result = $this->waterService->addGlass($userId);

        return response()->json($result['data'], $result['status']);
    }

    public function getDailyStats(): JsonResponse
    {
        $result = $this->waterService->getDailyStats(auth()->id());

        return response()->json($result['data'], $result['status']);
    }

    public function getOverallStats(): JsonResponse
    {
        $result = $this->waterService->getOverallStats(auth()->id());

        return response()->json($result['data'], $result['status']);
    }
}
