<?php

namespace App\Modules\Finance\Services;

use App\Models\FinanceCategory;
use App\Modules\Finance\ServiceInterfaces\CategoryServiceInterface;
use Illuminate\Database\Eloquent\Collection;

class CategoryService implements CategoryServiceInterface
{

    public function create(
        int $userId,
        string $name,
        string $type,
        ?string $icon,
    ): FinanceCategory
    {
        return FinanceCategory::create([
            'user_id' => $userId,
            'name' => $name,
            'type' => $type,
            'icon' => $icon,
        ]);
    }

    public function getByUserAndType(
        int $userId,
        ?string $type
    ): Collection
    {
        $query = FinanceCategory::where('user_id', $userId);

        if ($type) {
            $query->where('type', $type);
        }

        return $query->get();
    }
}
