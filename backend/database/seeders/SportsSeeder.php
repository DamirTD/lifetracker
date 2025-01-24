<?php

namespace Database\Seeders;

use App\Models\Sport;
use Illuminate\Database\Seeder;

class SportsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $sports = [
            ['name' => 'Зал'],
            ['name' => 'Бег'],
            ['name' => 'Плавание'],
            ['name' => 'Велоспорт'],
            ['name' => 'Йога'],
            ['name' => 'Теннис'],
            ['name' => 'Бокс'],
            ['name' => 'Гимнастика'],
            ['name' => 'Ходьба'],
            ['name' => 'Футбол'],
            ['name' => 'Баскетбол'],
            ['name' => 'Волейбол'],
            ['name' => 'Горные лыжи'],
            ['name' => 'Скалолазание'],
            ['name' => 'Катание на коньках'],
        ];

        foreach ($sports as $sport) {
            Sport::create($sport);
        }
    }
}
