<?php

namespace App\Modules\Finance\ServiceInterfaces;

interface KaspiPDFAnalyzerServiceInterface
{
    public function analyze(array $transactions): array;
}
