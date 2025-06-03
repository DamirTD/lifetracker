<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @method static when(array|string|null $search, \Closure $param)
 */
class Food extends Model
{
    use HasFactory;

    protected $table = 'food';

    protected $fillable = [
        'name', 'calories', 'protein', 'fat', 'carbohydrates'
    ];

    protected $casts = [
        'calories'      => 'integer',
        'protein'       => 'float',
        'fat'           => 'float',
        'carbohydrates' => 'float',
    ];

    public function dietEntries(): HasMany
    {
        return $this->hasMany(DietEntry::class);
    }

    public function scopeSearch($query, $search): void
    {
        if ($search) {
            $query->where('name', 'like', "%{$search}%");
        }
    }
}
