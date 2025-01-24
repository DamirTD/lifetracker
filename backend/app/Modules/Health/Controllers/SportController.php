<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Sport;
use App\Models\TrainingProgram;
use App\Models\UserSport;
use App\Modules\Health\Requests\AnalyzeSportRequest;
use App\Modules\Health\Requests\SelectSportRequest;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;

class SportController extends Controller
{
    public function getSportTypes(): JsonResponse
    {
        $sports = Sport::all(['id', 'name']);

        return response()->json(['sports' => $sports]);
    }

    public function selectSport(SelectSportRequest $request): JsonResponse
    {
        $data = $request->validated();

        $userSport = UserSport::updateOrCreate(
            [
                'user_id'  => auth()->id(),
                'sport_id' => $data['sport_id'],
            ],
            [
                'goal' => $data['goal'],
            ]
        );

        return response()->json([
            'message' => 'Спорт и цель успешно выбраны.',
            'data' => $userSport,
        ]);
    }

    public function analyzeSport(AnalyzeSportRequest $request): JsonResponse
    {
        $data = $request->validated();

        $program = TrainingProgram::where('sport', $data['sport'])
            ->where('goal', $data['goal'])
            ->first();

        if (!$program) {
            return response()->json([
                'message' => 'Программа для выбранного спорта и цели не найдена.',
            ], HttpStatusCodes::NOT_FOUND);
        }

        return response()->json([
            'message' => 'Анализ завершен.',
            'advice'  => $program->recommendation,
        ]);
    }
}
