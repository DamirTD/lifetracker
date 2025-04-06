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
        'date'     => 'date',
        'quantity' => 'float',
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
            'id'            => $this->id,
            'food_id'       => $this->food_id,
            'food_name'     => $food->name,
            'quantity'      => $this->quantity,
            'date'          => $this->date->format('Y-m-d'),
            'meal_type'     => $this->meal_type,
            'calories'      => round($food->calories * $ratio),
            'protein'       => round($food->protein * $ratio, 1),
            'fat'           => round($food->fat * $ratio, 1),
            'carbohydrates' => round($food->carbohydrates * $ratio, 1)
        ];
    }
}
