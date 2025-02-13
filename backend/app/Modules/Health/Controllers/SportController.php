<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Sport;
use App\Models\TrainingProgram;
use App\Models\UserSport;
use App\Models\UserTrainingProgram;
use App\Modules\Health\Helpers\UserTrainingProgramHelper;
use App\Modules\Health\Requests\BasicSportRequest;
use App\Modules\Health\Requests\CompleteTrainingRequest;
use App\Modules\Health\Requests\SelectSportRequest;
use App\Modules\Health\Requests\UpdateSportRequest;
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
     * @OA\Get(
     *     path="/api/sport/user-sport",
     *     summary="Получить виды спорта пользователя",
     *     tags={"Sport"},
     *     security={{"sanctum": {}}},
     *     @OA\Response(
     *         response=200,
     *         description="Список видов спорта пользователя",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Список видов спорта пользователя."),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="user_id", type="integer", example=5),
     *                     @OA\Property(property="sport_id", type="integer", example=2),
     *                     @OA\Property(property="goal", type="string", example="Похудение"),
     *                     @OA\Property(property="name", type="string", example="Моя программа тренировок"),
     *                     @OA\Property(property="recommendation", type="string", example="Уделять внимание кардио."),
     *                     @OA\Property(property="created_at", type="string", format="date-time", example="2025-02-13 09:56:29"),
     *                     @OA\Property(property="updated_at", type="string", format="date-time", example="2025-02-13 09:56:29"),
     *                     @OA\Property(property="sport", type="object",
     *                         @OA\Property(property="id", type="integer", example=2),
     *                         @OA\Property(property="name", type="string", example="Футбол")
     *                     )
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function getUserSport(): JsonResponse
    {
        $userId = auth()->id();

        $userSports = UserTrainingProgram::with('sport')
            ->where('user_id', $userId)
            ->get();

        return response()->json([
            'message' => 'Список видов спорта пользователя.',
            'data'    => $userSports
        ]);
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
     *     path="/api/sport/basic-training-program",
     *     summary="Базовая программа выбранного спорта и цели",
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
    public function basicTrainingProgram(BasicSportRequest $request): JsonResponse
    {
        $data = $request->validated();

        Sport::find($data['sport_id']);

        $program = TrainingProgram::where('sport_id', $data['sport_id'])
            ->where('goal', $data['goal'])
            ->first();

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

    /**
     * @OA\Put(
     *     path="/api/sport/edit/{id}",
     *     summary="Редактировать вид спорта",
     *     tags={"Sport"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID вида спорта",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="name", type="string", example="Баскетбол")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Вид спорта успешно обновлён",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта успешно обновлён."),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Баскетбол")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Вид спорта не найден",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта не найден.")
     *         )
     *     )
     * )
     */
    public function editSport(UpdateSportRequest $request, int $id): JsonResponse
    {
        $sport = UserTrainingProgram::find($id);

        $sport->update($request->validated());

        return response()->json([
            'message' => 'Вид спорта успешно обновлён.',
            'data' => $sport
        ], HttpStatusCodes::OK);
    }

    /**
     * @OA\Delete(
     *     path="/api/sport/{id}",
     *     summary="Удалить вид спорта",
     *     tags={"Sport"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID вида спорта",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Вид спорта успешно удалён",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта успешно удалён.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Вид спорта не найден",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта не найден.")
     *         )
     *     )
     * )
     */
    public function deleteSport(int $id): JsonResponse
    {
        $sport = UserTrainingProgram::find($id);

        $sport->delete();

        return response()->json(['message' => 'Вид спорта успешно удалён.'], HttpStatusCodes::OK);
    }
}
