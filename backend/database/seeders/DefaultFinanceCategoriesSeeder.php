<?php

namespace Database\Seeders;

use App\Models\FinanceCategory;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Modules\Finance\Defaults\DefaultFinanceCategories;
use App\Modules\Finance\ServiceInterfaces\CategoryServiceInterface;

class DefaultFinanceCategoriesSeeder extends Seeder
{
    public function run(): void
    {
        $categoryService = app(CategoryServiceInterface::class);
        $users = User::all();

        foreach ($users as $user) {
            foreach (DefaultFinanceCategories::get() as $cat) {
                $exists = FinanceCategory::where('user_id', $user->id)
                    ->where('name', $cat['name'])
                    ->where('type', $cat['type'])
                    ->exists();

                if (!$exists) {
                    $categoryService->create($user->id, $cat['name'], $cat['type'], $cat['icon']);
                }
            }
        }

        $this->command->info('Базовые категории добавлены (без дубликатов).');
    }
}
