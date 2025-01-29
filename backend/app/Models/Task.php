<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Task extends Model {
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'priority',
        'category',
        'due_date',
        'is_completed',
    ];

    protected $casts = [
        'due_date'     => 'datetime',
        'is_completed' => 'boolean',
    ];

    public function user(): BelongsTo {
        return $this->belongsTo(User::class);
    }
}
