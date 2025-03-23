<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserWaterContainer extends Model
{
    use HasFactory;

    protected $fillable = [
    'user_id',
    'name',
    'volume_ml',
    'icon',
    'color',
    'is_default',
];

    protected $casts = [
    'volume_ml' => 'integer',
    'is_default' => 'boolean',
];

    public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}
}
