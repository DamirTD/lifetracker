<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserWaterProgress extends Model
{
    protected $fillable = [
        'consumed_ml',
        'daily_goal_ml',
        'remaining_ml',
        'glass_volume_ml',
        'user_id',
        'date',
    ];


    public $timestamps = false;

    protected $casts = [
        'date' => 'date',
    ];
}
