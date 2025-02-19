<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\UserTrainingProgram;
use App\Models\TrainingSection;
use App\Models\Exercise;

class UserTrainingProgramSeeder extends Seeder
{
    public function run(): void
    {
        $programs = [
            [
                'user_id' => 1,
                'sport_id' => 1,
                'goal' => 'Набор массы',
                'name' => 'Силовые тренировки',
                'recommendation' => 'Не забывать про отдых',
                'sections' => [
                    [
                        'name' => 'Грудь + трицепс',
                        'exercises' => [
                            ['name' => 'Жим лёжа', 'reps' => 10, 'video_url' => 'https://youtube.com/example'],
                            ['name' => 'Отжимания', 'reps' => 15],
                        ],
                    ],
                    [
                        'name' => 'Спина + бицепс',
                        'exercises' => [
                            ['name' => 'Подтягивания', 'reps' => 12],
                        ],
                    ],
                ],
            ],
        ];

        foreach ($programs as $programData) {
            $program = UserTrainingProgram::create([
                'user_id' => $programData['user_id'],
                'sport_id' => $programData['sport_id'],
                'goal' => $programData['goal'],
                'name' => $programData['name'],
                'recommendation' => $programData['recommendation'],
            ]);

            foreach ($programData['sections'] as $sectionData) {
                $section = TrainingSection::create([
                    'user_training_program_id' => $program->id,
                    'name' => $sectionData['name'],
                ]);

                foreach ($sectionData['exercises'] as $exerciseData) {
                    Exercise::create([
                        'training_section_id' => $section->id,
                        'name' => $exerciseData['name'],
                        'reps' => $exerciseData['reps'],
                        'video_url' => $exerciseData['video_url'] ?? null,
                    ]);
                }
            }
        }
    }
}
