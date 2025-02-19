<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TrainingSection extends Model
{
    use HasFactory;

    protected $fillable = ['training_program_id', 'name'];

    public function trainingProgram(): BelongsTo
    {
        return $this->belongsTo(UserTrainingProgram::class);
    }

    public function exercises(): HasMany
    {
        return $this->hasMany(Exercise::class);
    }
}
