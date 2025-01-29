<?php

namespace Database\Seeders;

use App\Models\Food;
use Illuminate\Database\Seeder;

class FoodSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Food::create([
            'name' => 'Chicken Breast',
            'calories' => 200,
            'protein' => 30,
            'fat' => 5,
            'carbohydrates' => 0,
        ]);

        Food::create([
            'name' => 'Rice',
            'calories' => 130,
            'protein' => 3,
            'fat' => 0,
            'carbohydrates' => 28,
        ]);

        Food::create([
            'name' => 'Broccoli',
            'calories' => 55,
            'protein' => 5,
            'fat' => 1,
            'carbohydrates' => 11,
        ]);

        Food::create([
            'name' => 'Apple',
            'calories' => 95,
            'protein' => 0.5,
            'fat' => 0.3,
            'carbohydrates' => 25,
        ]);

        Food::create([
            'name' => 'Salmon',
            'calories' => 232,
            'protein' => 25,
            'fat' => 14,
            'carbohydrates' => 0,
        ]);
    }
}
