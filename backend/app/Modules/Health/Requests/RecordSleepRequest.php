<?php

namespace App\Modules\Health\Requests;

use Illuminate\Foundation\Http\FormRequest;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="RecordSleepRequest",
 *     type="object",
 *     required={"bedtime", "wake_up_time"},
 *     @OA\Property(
 *         property="bedtime",
 *         type="string",
 *         format="time",
 *         example="23:30",
 *         description="Время отхода ко сну (в формате ЧЧ:ММ)"
 *     ),
 *     @OA\Property(
 *         property="wake_up_time",
 *         type="string",
 *         format="time",
 *         example="07:00",
 *         description="Время пробуждения (в формате ЧЧ:ММ)"
 *     ),
 *     @OA\Property(
 *         property="interruptions",
 *         type="array",
 *         nullable=true,
 *         description="Список прерываний сна",
 *         @OA\Items(
 *             @OA\Property(
 *                 property="time",
 *                 type="string",
 *                 format="time",
 *                 example="02:15",
 *                 description="Время прерывания"
 *             ),
 *             @OA\Property(
 *                 property="reason",
 *                 type="string",
 *                 example="Шум",
 *                 description="Причина прерывания"
 *             )
 *         )
 *     )
 * )
 */
class RecordSleepRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'bedtime'                => 'required|date_format:H:i',
            'wake_up_time'           => 'required|date_format:H:i',
            'interruptions'          => 'nullable|array',
            'interruptions.*.time'   => 'required_with:interruptions|date_format:H:i',
            'interruptions.*.reason' => 'required_with:interruptions|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'bedtime.required'                     => 'Время отхода ко сну обязательно для заполнения.',
            'bedtime.date_format'                  => 'Время отхода ко сну должно быть в формате ЧЧ:ММ.',
            'wake_up_time.required'                => 'Время пробуждения обязательно для заполнения.',
            'wake_up_time.date_format'             => 'Время пробуждения должно быть в формате ЧЧ:ММ.',
            'interruptions.array'                  => 'Прерывания сна должны быть представлены в виде массива.',
            'interruptions.*.time.required_with'   => 'Поле времени прерывания обязательно при наличии прерываний.',
            'interruptions.*.time.date_format'     => 'Время прерывания должно быть в формате ЧЧ:ММ.',
            'interruptions.*.reason.required_with' => 'Причина прерывания обязательна при наличии времени прерывания.',
            'interruptions.*.reason.string'        => 'Причина прерывания должна быть строкой.',
            'interruptions.*.reason.max'           => 'Причина прерывания не должна превышать 255 символов.',
        ];
    }
}
