<?php

namespace App\Modules\Finance\ServiceInterfaces;

use Illuminate\Http\UploadedFile;

interface FinanceImportServiceInterface
{
    /**
     * @param int $userId
     * @param UploadedFile $file
     * @return int Number of imported records
     */
    public function import(
        int $userId,
        UploadedFile $file
    ): int;
}
