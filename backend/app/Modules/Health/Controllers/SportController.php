<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Sport;
use App\Models\TrainingProgram;
use App\Models\UserSport;
use App\Modules\Health\Helpers\UserTrainingProgramHelper;
use App\Modules\Health\Requests\AnalyzeSportRequest;
use App\Modules\Health\Requests\CompleteTrainingRequest;
use App\Modules\Health\Requests\SelectSportRequest;
use App\Modules\Health\Requests\UserTrainingRequest;
use App\Utils\Constants\HttpStatusCodes;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

class SportController extends Controller
{
    public function __construct(
        protected UserTrainingProgramHelper $trainingProgramHelper
    ){
    }

    /**
     * @OA\Get(
     *     path="/api/sports",
     *     summary="Получить список видов спорта",
     *     tags={"Sport"},
     *     @OA\Response(
     *         response=200,
     *         description="Список всех видов спорта",
     *         @OA\JsonContent(
     *             @OA\Property(property="sports", type="array", @OA\Items(
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Футбол")
     *             ))
     *         )
     *     )
     * )
     */
    public function getSportTypes(): JsonResponse
    {
        $sports = Sport::all(['id', 'name']);

        return response()->json(['sports' => $sports]);
    }

    /**
     * @OA\Post(
     *     path="/api/sports/select",
     *     summary="Выбрать вид спорта и цель",
     *     tags={"Sport"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="sport_id", type="integer", example=1),
     *             @OA\Property(property="goal", type="string", example="Похудение")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Спорт и цель успешно выбраны",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Спорт и цель успешно выбраны."),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="user_id", type="integer", example=5),
     *                 @OA\Property(property="sport_id", type="integer", example=1),
     *                 @OA\Property(property="goal", type="string", example="Похудение")
     *             )
     *         )
     *     )
     * )
     */
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

    /**
     * @OA\Post(
     *     path="/api/sport/analyze",
     *     summary="Анализ выбранного спорта и цели",
     *     tags={"Sport"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="sport", type="string", example="Бег"),
     *             @OA\Property(property="goal", type="string", example="Похудеть")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Анализ завершен",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Анализ завершен."),
     *             @OA\Property(property="advice", type="string", example="Рекомендуется 3 тренировки в неделю.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Программа для выбранного спорта и цели не найдена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Программа для выбранного спорта и цели не найдена.")
     *         )
     *     )
     * )
     */
    public function analyzeSport(AnalyzeSportRequest $request): JsonResponse
    {
        $data = $request->validated();

        $sport = Sport::find($data['sport_id']);

        if (!$sport) {
            return response()->json([
                'message' => 'Выбранный вид спорта не найден.'
            ], HttpStatusCodes::NOT_FOUND);
        }

        $program = TrainingProgram::where('sport_id', $data['sport_id'])
            ->where('goal', $data['goal'])
            ->first();

        if (!$program) {
            return response()->json([
                'message' => 'Программа для выбранного спорта и цели не найдена.'
            ], HttpStatusCodes::NOT_FOUND);
        }

        return response()->json([
            'message' => 'Анализ завершен.',
            'advice'  => $program->recommendation,
        ], HttpStatusCodes::OK);
    }

    /**
     * @OA\Post(
     *     path="/api/training-programs",
     *     summary="Добавить пользовательскую тренировочную программу",
     *     tags={"Training Program"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="sport_id", type="integer", example=1),
     *             @OA\Property(property="goal", type="string", example="Похудение"),
     *             @OA\Property(property="name", type="string", example="Моя программа тренировок"),
     *             @OA\Property(property="recommendation", type="string", nullable=true, example="Уделять внимание кардио.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Программа успешно добавлена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Тренировочная программа успешно добавлена."),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=10),
     *                 @OA\Property(property="user_id", type="integer", example=5),
     *                 @OA\Property(property="sport_id", type="integer", example=1),
     *                 @OA\Property(property="goal", type="string", example="Похудение"),
     *                 @OA\Property(property="name", type="string", example="Моя программа тренировок"),
     *                 @OA\Property(property="recommendation", type="string", example="Уделять внимание кардио.")
     *             )
     *         )
     *     )
     * )
     */
    public function addUserTrainingProgram(UserTrainingRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $program = $this->trainingProgramHelper->createUserTrainingProgram($validated);

        return response()->json([
            'message' => 'Тренировочная программа успешно добавлена.',
            'data' => $program,
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/training-programs/complete",
     *     summary="Завершить тренировку и записать в историю",
     *     tags={"Training Program"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="training_program_id", type="integer", example=10),
     *             @OA\Property(property="duration", type="integer", example=60),
     *             @OA\Property(property="calories_burned", type="integer", example=300)
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Тренировка завершена, история добавлена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Тренировка завершена, история добавлена.")
     *         )
     *     )
     * )
     */
    public function completeTraining(CompleteTrainingRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $this->trainingProgramHelper->completeUserTraining($validated);

        return response()->json([
            'message' => 'Тренировка завершена, история добавлена.',
        ]);
    }
}
