<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserTrainingProgram extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'sport_id', 'goal', 'name', 'recommendation'];

    public function sport(): BelongsTo
    {
        return $this->belongsTo(Sport::class);
    }
}
