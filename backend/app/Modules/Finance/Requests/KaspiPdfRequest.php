<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;


class KaspiPdfRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'file'      => 'required|file|mimes:pdf|max:10240',
            'sortBy'    => 'nullable|string|in:date,amount,operation',
            'sortOrder' => 'nullable|string|in:asc,desc',
        ];
    }

    public function messages(): array
    {
        return [
            'file.required' => 'Вы должны загрузить файл.',
            'file.file'     => 'Загружаемый файл должен быть корректным.',
            'file.mimes'    => 'Файл должен быть в формате PDF.',
            'file.max'      => 'Файл не должен превышать 10MB.',
            'sortBy.in'     => 'Сортировка может быть только по полям: date, amount, operation.',
            'sortOrder.in'  => 'Порядок сортировки должен быть либо "asc", либо "desc".',
        ];
    }

    public function getSortBy(): ?string
    {
        return $this->query('sortBy');
    }

    public function getSortOrder(): string
    {
        return $this->query('sortOrder', 'desc');
    }
}
