<?php

namespace App\Modules\Finance\ServiceInterfaces;

interface FinanceAdviceServiceInterface
{
    public function calculateBreakdown(float $salary, string $rule): array;
    public function getAdvice(string $rule): array;
}
