<?php

namespace App\Modules\Health\Helpers;

use App\Http\Controllers\Controller;
use App\Models\TrainingHistory;
use App\Models\UserTrainingProgram;

class UserTrainingProgramHelper extends Controller
{
    public function createUserTrainingProgram(array $validated): UserTrainingProgram
    {
        $program = UserTrainingProgram::create([
            'user_id'        => auth()->id(),
            'sport_id'       => $validated['sport_id'],
            'goal'           => $validated['goal'],
            'name'           => $validated['name'],
            'recommendation' => $validated['recommendation'] ?? null,
        ]);

        foreach ($validated['sections'] as $sectionData) {
            $section = $program->sections()->create([
                'name' => $sectionData['name'],
            ]);

            foreach ($sectionData['exercises'] as $exerciseData) {
                $section->exercises()->create([
                    'name'      => $exerciseData['name'],
                    'reps'      => $exerciseData['reps'],
                    'video_url' => $exerciseData['video_url'] ?? null,
                ]);
            }
        }

        return $program->load('sections.exercises');
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
