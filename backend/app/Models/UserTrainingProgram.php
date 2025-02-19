<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class UserTrainingProgram extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'sport_id', 'goal', 'name', 'recommendation'];

    public function sport(): BelongsTo
    {
        return $this->belongsTo(Sport::class);
    }

    public function sections(): HasMany
    {
        return $this->hasMany(TrainingSection::class);
    }
}
