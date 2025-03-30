<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ImportDeviceDataRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'device_type' => 'required|string|in:fitbit,garmin,apple_health,samsung_health,other',
            'data' => 'required|array',
            'data.*.start_time' => 'required_if:device_type,other|string',
            'data.*.end_time' => 'required_if:device_type,other|string',
            'data.*.interruptions' => 'nullable|array',
        ];
    }

    public function attributes(): array
    {
        return [
            'device_type' => 'тип устройства',
            'data' => 'данные с устройства',
            'data.*.start_time' => 'время начала сна',
            'data.*.end_time' => 'время конца сна',
            'data.*.interruptions' => 'прерывания сна',
        ];
    }

    public function messages(): array
    {
        return [
            'device_type.in' => 'Тип устройства должен быть одним из следующих: fitbit, garmin, apple_health, samsung_health, other',
            'data.required'  => 'Необходимо предоставить данные с устройства',
            'data.array'     => 'Данные с устройства должны быть представлены в виде массива',
        ];
    }
}
