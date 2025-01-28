<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
    ];

    protected $casts = [
        'interruptions' => 'array',
    ];
}
