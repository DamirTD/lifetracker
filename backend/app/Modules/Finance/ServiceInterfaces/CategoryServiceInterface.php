<?php

namespace App\Modules\Finance\ServiceInterfaces;

use App\Models\FinanceCategory;
use Illuminate\Database\Eloquent\Collection;

interface CategoryServiceInterface
{
    /**
     * @param int $userId
     * @param string $name
     * @param string $type
     * @param string|null $icon
     * @return FinanceCategory
     */
    public function create(
        int $userId,
        string $name,
        string $type,
        ?string $icon,
    ): FinanceCategory;

    /**
     * @param int $userId
     * @param string|null $type
     * @return Collection
     */
    public function getByUserAndType(
        int $userId,
        ?string $type
    ): Collection;
}
