<?php

namespace App\Modules\Health\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class FoodResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'            => $this->id,
            'name'          => $this->name,
            'calories'      => $this->calories,
            'protein'       => $this->protein,
            'fat'           => $this->fat,
            'carbohydrates' => $this->carbohydrates,
        ];
    }
}
