<?php

namespace App\Modules\Finance\ServiceInterfaces;

interface FinanceAdviceServiceInterface
{
    /**
     * @param float $salary
     * @param string $rule
     * @return array
     */
    public function calculateBreakdown(float $salary, string $rule): array;

    /**
     * @param string $rule
     * @return array
     */
    public function getAdvice(string $rule): array;

    /**
     * @param int $userId
     * @return array
     */
    public function getPersonalizedAdvice(int $userId): array;
}
