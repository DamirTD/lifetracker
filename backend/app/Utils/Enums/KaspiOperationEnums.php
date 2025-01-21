<?php

namespace App\Utils\Enums;

enum KaspiOperationEnums: string
{
    case Purchase      = 'Покупка';
    case Replenishment = 'Пополнение';
    case Transfer      = 'Перевод';
}
