<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\Helpers\FinanceHelper;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use Carbon\Carbon;

class FinanceAdviceService implements FinanceAdviceServiceInterface
{
    public function __construct(
        protected FinanceRecordQueryInterface $recordQuery
    ) {
    }

    /**
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
            '80-10-10' => [
                "Большая часть вашего дохода идет на обязательные расходы - следите за ними внимательно.",
                "Несмотря на ограниченный бюджет на желания и сбережения, важно соблюдать эти пропорции.",
                "Ищите способы увеличить доход или сократить обязательные расходы для большей гибкости."
            ],
        ];

        return $advice[$rule] ?? [];
    }

    /**
     * @param int $userId
     * @return array
     */
    public function getPersonalizedAdvice(int $userId): array
    {
        $advice = [];

        $startDate = Carbon::now()->subMonths(3)->format('Y-m-d');
        $endDate   = Carbon::now()->format('Y-m-d');

        $records = $this->recordQuery->getFilteredRecords(
            $userId,
            'month',
            null,
            null,
            $startDate,
            $endDate,
            'date',
            'desc',
            1,
            500
        )->items();

        $totalIncome  = collect($records)->where('type', 'income')->sum('amount');
        $totalExpense = collect($records)->where('type', 'expense')->sum('amount');
        $totalSaving  = collect($records)->where('type', 'saving')->sum('amount');

        if ($totalIncome > 0) {
            $savingRate = ($totalSaving / $totalIncome) * 100;

            if ($savingRate < 10) {
                $advice[] = [
                    'title'       => 'Увеличьте норму сбережений',
                    'description' => 'Ваша текущая норма сбережений составляет менее 10%. Старайтесь откладывать минимум 15-20% от дохода.',
                    'type'        => 'saving'
                ];
            } elseif ($savingRate >= 20) {
                $advice[] = [
                    'title'       => 'Отличная работа!',
                    'description' => 'Вы сберегаете более 20% от своего дохода. Рассмотрите возможность инвестирования части этих средств для долгосрочного роста.',
                    'type'        => 'investment'
                ];
            }

            $expenseRate = ($totalExpense / $totalIncome) * 100;
            if ($expenseRate > 80) {
                $advice[] = [
                    'title'       => 'Внимание на расходы',
                    'description' => 'Ваши расходы составляют более 80% от дохода. Попробуйте найти категории, на которых можно сэкономить.',
                    'type'        => 'expense'
                ];
            }
        }

        $generalAdvice = [
            [
                'title'       => 'Создайте чрезвычайный фонд',
                'description' => 'Старайтесь иметь сбережения, равные 3-6 месячным расходам, на случай непредвиденных обстоятельств.',
                'type'        => 'saving'
            ],
            [
                'title'       => 'Автоматизируйте сбережения',
                'description' => 'Настройте автоматические переводы части зарплаты на сберегательный счет в день получения дохода.',
                'type'        => 'saving'
            ],
            [
                'title'       => 'Отслеживайте подписки',
                'description' => 'Регулярно проверяйте активные подписки и отказывайтесь от тех, которыми вы не пользуетесь.',
                'type'        => 'expense'
            ],
            [
                'title'       => 'Диверсифицируйте инвестиции',
                'description' => 'Не держите все яйца в одной корзине - распределите инвестиции между разными классами активов.',
                'type'        => 'investment'
            ]
        ];

        if (count($advice) < 3) {
            $needed = 3 - count($advice);
            $advice = array_merge($advice, array_slice($generalAdvice, 0, $needed));
        }

        return $advice;
    }
}
