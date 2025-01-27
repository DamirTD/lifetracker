<?php

namespace App\Modules\Health\Helpers;

use App\Http\Controllers\Controller;
use App\Models\TrainingHistory;
use App\Models\UserTrainingProgram;

class UserTrainingProgramHelper extends Controller
{
    public function createUserTrainingProgram(array $validated): UserTrainingProgram
    {
        return UserTrainingProgram::create([
            'user_id'        => auth()->id(),
            'sport_id'       => $validated['sport_id'],
            'goal'           => $validated['goal'],
            'name'           => $validated['name'],
            'recommendation' => $validated['recommendation'],
        ]);
    }

    public function completeUserTraining(array $validated): void
    {
        $userTrainingProgram = UserTrainingProgram::find($validated['training_program_id']);

        TrainingHistory::create([
            'user_id'             => auth()->id(),
            'training_program_id' => $userTrainingProgram->id,
            'date'                => now(),
            'duration'            => $validated['duration'],
            'calories_burned'     => $validated['calories_burned'],
        ]);
    }
}
