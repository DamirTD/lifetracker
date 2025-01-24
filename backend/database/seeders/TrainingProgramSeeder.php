<?php

namespace Database\Seeders;

use App\Models\TrainingProgram;
use Illuminate\Database\Seeder;

class TrainingProgramSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        TrainingProgram::insert([
            [
                'sport' => 'Зал',
                'goal' => 'накачаться',
                'recommendation' => 'Рекомендуемая программа: 4 тренировки в неделю с упором на силу.',
            ],
            [
                'sport' => 'Зал',
                'goal' => 'похудеть',
                'recommendation' => 'Тренируйтесь 5 раз в неделю с акцентом на кардио и круговые тренировки.',
            ],
            [
                'sport' => 'Бег',
                'goal' => 'накачаться',
                'recommendation' => 'Дополните бег силовыми тренировками 3 раза в неделю.',
            ],
            [
                'sport' => 'Бег',
                'goal' => 'похудеть',
                'recommendation' => 'Бегайте 3-4 раза в неделю, чередуя медленный бег с интервальным.',
            ],
        ]);
    }
}
