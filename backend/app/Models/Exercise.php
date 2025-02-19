<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Exercise extends Model
{
    use HasFactory;

    protected $fillable = ['section_id', 'name', 'reps', 'video_url'];

    public function section(): BelongsTo
    {
        return $this->belongsTo(TrainingSection::class);
    }
}
