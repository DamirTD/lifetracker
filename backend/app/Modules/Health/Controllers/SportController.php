<?php

namespace App\Modules\Health\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Sport;
use App\Models\TrainingProgram;
use App\Models\UserSport;
use App\Models\UserTrainingProgram;
use App\Models\TrainingHistory;
use App\Modules\Health\Helpers\UserTrainingProgramHelper;
use App\Modules\Health\Requests\BasicSportRequest;
use App\Modules\Health\Requests\CompleteTrainingRequest;
use App\Modules\Health\Requests\SelectSportRequest;
use App\Modules\Health\Requests\UpdateSportRequest;
use App\Modules\Health\Requests\UserTrainingRequest;
use Illuminate\Http\JsonResponse;

class SportController extends Controller
{
    public function __construct(
        protected UserTrainingProgramHelper $trainingProgramHelper
    ){
    }

    /**
     * @OA\Get(
     *     path="/api/sport/list",
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
    public function getSportList(): JsonResponse
    {
        return $this->wrap(request(), function () {
            $sports = Sport::all(['id', 'name']);
            return ['sports' => $sports];
        });
    }

    /**
     * @OA\Get(
     *     path="/api/sport/user-sport-list",
     *     summary="Получить список видов спорта пользователя",
     *     tags={"Sport"},
     *     @OA\Response(
     *         response=200,
     *         description="Список видов спорта пользователя",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Список видов спорта пользователя."),
     *             @OA\Property(property="data", type="array", @OA\Items(
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="Футбол")
     *             ))
     *         )
     *     )
     * )
     */
    public function getUserSportList(): JsonResponse
    {
        return $this->wrap(request(), function () {
            $userId = auth()->id();
            $userSports = UserSport::with('sport:name,id')
                ->where('user_id', $userId)
                ->get()
                ->pluck('sport');

            return [
                'message' => 'Список видов спорта пользователя.',
                'data'    => $userSports
            ];
        });
    }

    /**
     * @OA\Post(
     *     path="/api/sport/select-user-sport",
     *     summary="Выбрать вид спорта",
     *     tags={"Sport"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="sport_id", type="integer", example=1)
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Спорт успешно выбран",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Спорт успешно выбран."),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="user_id", type="integer", example=5),
     *                 @OA\Property(property="sport_id", type="integer", example=1)
     *             )
     *         )
     *     )
     * )
     */
    public function selectUserSport(SelectSportRequest $request): JsonResponse
    {
        return $this->wrap($request, function ($data) {
            $userSport = UserSport::updateOrCreate(
                [
                    'user_id'  => auth()->id(),
                    'sport_id' => $data['sport_id'],
                ]
            );

            $message = $userSport->wasRecentlyCreated
                ? 'Спорт успешно выбран.'
                : 'Вы уже выбрали этот спорт.';

            return [
                'message' => $message,
                'data'    => $userSport,
            ];
        });
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
     *         description="Базовая тренировка найдена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Базовая тренировка найдена."),
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
        return $this->wrap($request, function ($data) {
            $program = TrainingProgram::where('sport_id', $data['sport_id'])
                ->where('goal', $data['goal'])
                ->firstOrFail();

            return [
                'message' => "Базовая тренировка найдена!",
                'advice'  => $program->recommendation,
            ];
        });
    }

    /**
     * @OA\Post(
     *     path="/api/sport/create-personal-training-program",
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
        return $this->wrap($request, function ($data) {
            $program = $this->trainingProgramHelper->createUserTrainingProgram($data);

            return [
                'message' => 'Тренировочная программа успешно добавлена.',
                'data'    => $program,
            ];
        });
    }

    /**
     * @OA\Post(
     *     path="/api/sport/complete-training",
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
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Ошибка валидации данных",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Ошибка валидации данных."),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Программа тренировки не найдена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Программа тренировки не найдена.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Внутренняя ошибка сервера",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Внутренняя ошибка сервера.")
     *         )
     *     )
     * )
     */
    public function completeTraining(CompleteTrainingRequest $request): JsonResponse
    {
        return $this->wrap($request, function ($data) use ($request) {
            $validated = $request->validated();
            $this->trainingProgramHelper->completeUserTraining($validated);

            return [
                'message' => 'Тренировка завершена, история добавлена.',
            ];
        });
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
        return $this->wrap($request, function () use ($id, $request) {
            $sport = Sport::findOrFail($id);
            $sport->update($request->validated());

            return [
                'message' => 'Вид спорта успешно обновлён.',
                'data' => $sport
            ];
        });
    }

    /**
     * @OA\Delete(
     *     path="/api/sport/user-sport/{id}",
     *     summary="Удалить вид спорта пользователя",
     *     tags={"Sport"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID пользовательского вида спорта",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Вид спорта пользователя успешно удалён",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта пользователя успешно удалён.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Вид спорта пользователя не найден",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Вид спорта пользователя не найден.")
     *         )
     *     )
     * )
     */
    public function deleteSport(int $id): JsonResponse
    {
        return $this->wrap(null, function () use ($id) {
            $userSport = UserSport::findOrFail($id);
            $userSport->delete();

            return ['message' => 'Вид спорта пользователя успешно удалён.'];
        });
    }

    /**
     * @OA\Get(
     *     path="/api/sport/training-program/{id}",
     *     summary="Получить данные о тренировочной программе",
     *     tags={"Training Program"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID тренировочной программы",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Данные о тренировочной программе",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Данные о тренировочной программе"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="user_id", type="integer", example=5),
     *                 @OA\Property(property="sport_id", type="integer", example=1),
     *                 @OA\Property(property="goal", type="string", example="Похудение"),
     *                 @OA\Property(property="name", type="string", example="Моя программа тренировок"),
     *                 @OA\Property(property="recommendation", type="string", example="Уделять внимание кардио.")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Тренировочная программа не найдена",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Тренировочная программа не найдена.")
     *         )
     *     )
     * )
     */
    public function getTrainingProgram(int $id): JsonResponse
    {
        return $this->wrap(request(), function () use ($id) {
            $program = UserTrainingProgram::with(['sport:id,name', 'sections'])
                ->findOrFail($id);

            return [
                'message' => 'Данные о тренировочной программе',
                'data' => $program
            ];
        });
    }

    /**
     * @OA\Get(
     *     path="/api/sport/training-history",
     *     summary="Получить историю тренировок пользователя",
     *     tags={"Training Program"},
     *     @OA\Response(
     *         response=200,
     *         description="История тренировок",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="История тренировок"),
     *             @OA\Property(property="data", type="array", @OA\Items(
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="user_id", type="integer", example=5),
     *                 @OA\Property(property="training_program_id", type="integer", example=10),
     *                 @OA\Property(property="duration", type="integer", example=60),
     *                 @OA\Property(property="calories_burned", type="integer", example=300),
     *                 @OA\Property(property="created_at", type="string", format="date-time", example="2023-01-15T12:00:00Z"),
     *                 @OA\Property(property="program", type="object",
     *                     @OA\Property(property="id", type="integer", example=10),
     *                     @OA\Property(property="name", type="string", example="Моя программа тренировок"),
     *                     @OA\Property(property="sport", type="object",
     *                         @OA\Property(property="id", type="integer", example=1),
     *                         @OA\Property(property="name", type="string", example="Бег")
     *                     )
     *                 )
     *             ))
     *         )
     *     )
     * )
     */
    public function getTrainingHistory(): JsonResponse
    {
        return $this->wrap(request(), function () {
            $history = TrainingHistory::with(['trainingProgram'])
                ->where('user_id', auth()->id())
                ->orderBy('created_at', 'desc')
                ->get();

            return [
                'message' => 'История тренировок',
                'data' => $history
            ];
        });
    }
}
