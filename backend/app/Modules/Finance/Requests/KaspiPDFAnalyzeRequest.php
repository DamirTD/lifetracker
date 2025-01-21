<?php

namespace App\Modules\Finance\Requests;

use Illuminate\Foundation\Http\FormRequest;

class KaspiPDFAnalyzeRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'transactions'             => ['required', 'array'],
            'transactions.*.date'      => ['required', 'date_format:d.m.y'],
            'transactions.*.operation' => ['required', 'string'],
            'transactions.*.amount'    => ['required', 'numeric'],
            'transactions.*.details'   => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'transactions.required'             => 'Поле transactions обязательно для заполнения.',
            'transactions.array'                => 'Поле transactions должно быть массивом.',
            'transactions.*.date.required'      => 'Поле date обязательно для каждой транзакции.',
            'transactions.*.date.date_format'   => 'Поле date должно быть в формате dd.mm.yy.',
            'transactions.*.operation.required' => 'Поле operation обязательно для каждой транзакции.',
            'transactions.*.amount.required'    => 'Поле amount обязательно для каждой транзакции.',
            'transactions.*.amount.numeric'     => 'Поле amount должно быть числом.',
            'transactions.*.amount.min'         => 'Поле amount должно быть больше или равно 0.',
            'transactions.*.details.string'     => 'Поле details должно быть строкой.',
        ];
    }

    public function transactions(): array
    {
        return $this->validated()['transactions'];
    }
}
