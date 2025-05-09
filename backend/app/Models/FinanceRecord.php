<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FinanceRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'amount',
        'type',
        'period',
        'description',
        'date',
        'is_recurring',
        'recurring_frequency',
    ];

    protected $casts = [
        'amount' => 'float',
        'date' => 'date',
        'is_recurring' => 'boolean',
    ];

    public $timestamps = true;

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(FinanceCategory::class);
    }

    public function getCategoryNameAttribute()
    {
        return optional($this->category)->name;
    }

}
