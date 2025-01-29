<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DietEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'food_id', 'quantity', 'date'
    ];

    public function food()
    {
        return $this->belongsTo(Food::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function calculateNutrients(): array
    {
        return [
            'calories'      => ($this->quantity / 100) * $this->food->calories,
            'protein'       => ($this->quantity / 100) * $this->food->protein,
            'fat'           => ($this->quantity / 100) * $this->food->fat,
            'carbohydrates' => ($this->quantity / 100) * $this->food->carbohydrates,
        ];
    }
}
