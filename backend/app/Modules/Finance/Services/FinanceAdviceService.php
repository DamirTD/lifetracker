<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\Helpers\FinanceHelper;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;

class FinanceAdviceService implements FinanceAdviceServiceInterface
{
    /**
     *
     * @param float $salary
     * @param string $rule
     * @return array
     */
    public function calculateBreakdown(float $salary, string $rule): array
    {
        $percentages = FinanceHelper::getPercentages($rule);

        return [
            'essentials' => round($salary * $percentages['essentials'], 2),
            'wants'      => round($salary * $percentages['wants'], 2),
            'savings'    => round($salary * $percentages['savings'], 2),
        ];
    }

    /**
     *
     * @param string $rule
     * @return array
     */
    public function getAdvice(string $rule): array
    {
        $advice = [
            '50-30-20' => [
                "Инвестируйте 20% от вашей зарплаты в долгосрочные активы.",
                "Попробуйте сократить ненужные расходы, если сумма на Wants превышает ваш бюджет.",
                "Убедитесь, что вы откладываете на чрезвычайный фонд как минимум 3-6 месяцев расходов."
            ],
            '70-20-10' => [
                "Сосредоточьтесь на важных тратах — они должны составлять 70% вашего дохода.",
                "Инвестируйте 10% в долгосрочные активы и 20% откладывайте на будущее.",
                "Создайте резервный фонд для стабильности."
            ],
            '60-20-20' => [
                "Уделяйте больше внимания своим желаниям и сбережениям.",
                "Планируйте крупные траты заранее.",
                "Соблюдайте баланс между Wants и Savings."
            ],
        ];

        return $advice[$rule] ?? [];
    }
}
