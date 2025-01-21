<?php

namespace App\Utils\Sort;

class KaspiPDFSorter
{
    /**
     * @param array  $transactions
     * @param string $sortBy
     * @param string $sortOrder
     * @return array
     */
    public static function sort(array $transactions, string $sortBy, string $sortOrder = 'asc'): array
    {
        $sortableFields = ['date', 'amount', 'details'];

        if (in_array($sortBy, $sortableFields)) {
            usort($transactions, function ($a, $b) use ($sortBy, $sortOrder) {
                if ($sortOrder === 'asc') {
                    return $a[$sortBy] <=> $b[$sortBy];
                }
                return $b[$sortBy] <=> $a[$sortBy];
            });
        }
        return $transactions;
    }
}
