<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DietEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'food_id', 'quantity', 'date', 'meal_type'
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function food(): BelongsTo
    {
        return $this->belongsTo(Food::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function calculateNutrients(): array
    {
        $food  = $this->food;
        $ratio = $this->quantity / 100;

        return [
            'calories'      => round($food->calories * $ratio),
            'protein'       => round($food->protein * $ratio),
            'fat'           => round($food->fat * $ratio),
            'carbohydrates' => round($food->carbohydrates * $ratio)
        ];
    }
}
