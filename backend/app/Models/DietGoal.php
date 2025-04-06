<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DietGoal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'calories', 'protein', 'fat', 'carbohydrates', 'is_active'
    ];

    protected $casts = [
        'calories'      => 'integer',
        'protein'       => 'float',
        'fat'           => 'float',
        'carbohydrates' => 'float',
        'is_active'     => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
