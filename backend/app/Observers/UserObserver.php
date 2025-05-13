<?php

namespace App\Observers;

use App\Models\FinanceCategory;
use App\Models\User;
use App\Modules\Finance\Defaults\DefaultFinanceCategories;

class UserObserver
{
    /**
     * Handle the User "created" event.
     */
    public function created(User $user): void
    {
        foreach (DefaultFinanceCategories::get() as $cat) {
            $exists = FinanceCategory::where('user_id', $user->id)
                ->where('name', $cat['name'])
                ->where('type', $cat['type'])
                ->exists();

            if (!$exists) {
                FinanceCategory::create([
                    'user_id' => $user->id,
                    'name'    => $cat['name'],
                    'type'    => $cat['type'],
                    'icon'    => $cat['icon'],
                ]);
            }
        }
    }

    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
        //
    }

    /**
     * Handle the User "deleted" event.
     */
    public function deleted(User $user): void
    {
        //
    }

    /**
     * Handle the User "restored" event.
     */
    public function restored(User $user): void
    {
        //
    }

    /**
     * Handle the User "force deleted" event.
     */
    public function forceDeleted(User $user): void
    {
        //
    }
}
