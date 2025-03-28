<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Sleep extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bedtime',
        'wake_up_time',
        'interruptions',
        'duration',
        'quality',
        'mood_on_waking',
        'sleep_environment',
        'device_data',
    ];

    protected $casts = [
        'interruptions'     => 'array',
        'sleep_environment' => 'array',
        'device_data'       => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
