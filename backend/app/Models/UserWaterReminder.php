<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserWaterReminder extends Model
{
    use HasFactory;

    protected $fillable = [
    'user_id',
    'start_time',
    'end_time',
    'interval_minutes',
    'days_of_week',
    'is_enabled',
    'message',
];

    protected $casts = [
        'days_of_week' => 'array',
    'interval_minutes' => 'integer',
    'is_enabled' => 'boolean',
];

    public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}
}
