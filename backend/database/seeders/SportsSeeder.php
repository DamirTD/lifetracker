<?php

namespace Database\Seeders;

use App\Models\Sport;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SportsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Sport::truncate();

        $sports = [
            ['id' => 1, 'name'  => 'Зал'],
            ['id' => 2, 'name'  => 'Бег'],
            ['id' => 3, 'name'  => 'Плавание'],
            ['id' => 4, 'name'  => 'Велоспорт'],
            ['id' => 5, 'name'  => 'Йога'],
            ['id' => 6, 'name'  => 'Теннис'],
            ['id' => 7, 'name'  => 'Бокс'],
            ['id' => 8, 'name'  => 'Гимнастика'],
            ['id' => 9, 'name'  => 'Ходьба'],
            ['id' => 10, 'name' => 'Футбол'],
            ['id' => 11, 'name' => 'Баскетбол'],
            ['id' => 12, 'name' => 'Волейбол'],
            ['id' => 13, 'name' => 'Горные лыжи'],
            ['id' => 14, 'name' => 'Скалолазание'],
            ['id' => 15, 'name' => 'Катание на коньках'],
        ];

        DB::table('sports')->insert($sports);

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
}
