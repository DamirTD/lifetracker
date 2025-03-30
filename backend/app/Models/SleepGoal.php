<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SleepGoal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'target_hours',
        'target_bedtime',
        'target_wake_time',
        'max_interruptions',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
