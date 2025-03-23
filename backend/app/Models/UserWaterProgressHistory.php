<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserWaterProgressHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date',
        'action',
        'volume_ml',
        'container_id',
        'timestamp',
        'daily_goal_ml',
        'glass_volume_ml',
        'calculation_factors',
    ];

    protected $casts = [
        'date' => 'date',
        'volume_ml' => 'integer',
        'container_id' => 'integer',
        'timestamp' => 'datetime',
        'daily_goal_ml' => 'integer',
        'glass_volume_ml' => 'integer',
        'calculation_factors' => 'json',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function container(): BelongsTo
    {
        return $this->belongsTo(UserWaterContainer::class, 'container_id');
    }
}
