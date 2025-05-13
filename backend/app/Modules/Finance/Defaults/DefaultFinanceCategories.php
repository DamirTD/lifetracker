<?php

namespace App\Modules\Finance\Defaults;

class DefaultFinanceCategories
{
    public static function get(): array
    {
        return [
            ['name' => 'Продукты',         'type' => 'expense',    'icon' => 'shopping-cart'],
            ['name' => 'Кафе и рестораны', 'type' => 'expense',    'icon' => 'coffee'],
            ['name' => 'Квартира',         'type' => 'expense',    'icon' => 'home'],
            ['name' => 'Интернет',         'type' => 'expense',    'icon' => 'wifi'],
            ['name' => 'Транспорт',        'type' => 'expense',    'icon' => 'bus'],
            ['name' => 'Здоровье',         'type' => 'expense',    'icon' => 'heartbeat'],
            ['name' => 'Образование',      'type' => 'expense',    'icon' => 'book'],
            ['name' => 'Подарки',          'type' => 'expense',    'icon' => 'gift'],
            ['name' => 'Развлечения',      'type' => 'expense',    'icon' => 'film'],
            ['name' => 'Одежда',           'type' => 'expense',    'icon' => 'tshirt'],
            ['name' => 'Коммунальные',     'type' => 'expense',    'icon' => 'bolt'],
            ['name' => 'Телефон',          'type' => 'expense',    'icon' => 'phone'],
            ['name' => 'Налоги и сборы',   'type' => 'expense',    'icon' => 'file-invoice-dollar'],

            ['name' => 'Зарплата',         'type' => 'income',     'icon' => 'dollar-sign'],
            ['name' => 'Фриланс',          'type' => 'income',     'icon' => 'briefcase'],
            ['name' => 'Подарок',          'type' => 'income',     'icon' => 'gift'],
            ['name' => 'Возврат',          'type' => 'income',     'icon' => 'undo'],

            ['name' => 'Депозит',          'type' => 'saving',     'icon' => 'piggy-bank'],
            ['name' => 'НЗ (резерв)',      'type' => 'saving',     'icon' => 'shield-alt'],

            ['name' => 'Акции',            'type' => 'investment', 'icon' => 'chart-line'],
            ['name' => 'Криптовалюта',     'type' => 'investment', 'icon' => 'bitcoin'],
            ['name' => 'Недвижимость',     'type' => 'investment', 'icon' => 'building'],
        ];
    }
}
