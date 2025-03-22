<?php

namespace App\Modules\Finance\Services;

use App\Modules\Finance\ServiceInterfaces\FinanceExportServiceInterface;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use Carbon\Carbon;
use FPDF;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class FinanceExportService implements FinanceExportServiceInterface
{
    public function __construct(
        protected FinanceRecordQueryInterface $recordQuery
    ) {
    }

    /**
     * @param int $userId
     * @param string $format
     * @param string $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $type
     * @return string File URL
     */
    public function export(
        int $userId,
        string $format,
        string $period,
        ?string $startDate,
        ?string $endDate,
        string $type
    ): string {
        $records = $this->getRecordsForExport($userId, $period, $startDate, $endDate, $type);

        return match ($format) {
            'excel' => $this->exportToExcel($records, $userId),
            'pdf'   => $this->exportToPdf($records, $userId),
            default => $this->exportToCsv($records, $userId),
        };
    }

    /**
     * @param int $userId
     * @param string $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @param string $type
     * @return array
     */
    private function getRecordsForExport(
        int $userId,
        string $period,
        ?string $startDate,
        ?string $endDate,
        string $type
    ): array {
        list($start, $end) = $this->getDateRange($period, $startDate, $endDate);

        $query = $this->recordQuery->getFilteredRecords(
            $userId,
            $period,
            $type !== 'all' ? $type : null,
            null,
            $start,
            $end,
            'date',
            'desc',
            1,
            10000
        );

        return $query->items();
    }

    /**
     * @param array $records
     * @param int $userId
     * @return string
     */
    private function exportToExcel(array $records, int $userId): string
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        $sheet->setCellValue('A1', 'Дата');
        $sheet->setCellValue('B1', 'Категория');
        $sheet->setCellValue('C1', 'Тип');
        $sheet->setCellValue('D1', 'Сумма');
        $sheet->setCellValue('E1', 'Описание');

        $row = 2;
        foreach ($records as $record) {
            $sheet->setCellValue('A' . $row, Carbon::parse($record->date)->format('Y-m-d'));
            $sheet->setCellValue('B' . $row, $record->category_name ?? '-');
            $sheet->setCellValue('C' . $row, $record->type);
            $sheet->setCellValue('D' . $row, $record->amount);
            $sheet->setCellValue('E' . $row, $record->description ?? '');
            $row++;
        }

        $filename = 'finances_' . $userId . '_' . date('YmdHis') . '.xlsx';
        $path = 'exports/' . $filename;

        $writer = new Xlsx($spreadsheet);
        $writer->save(storage_path('app/public/' . $path));

        return url('storage/' . $path);
    }

    /**
     * @param array $records
     * @param int $userId
     * @return string
     */
    private function exportToCsv(array $records, int $userId): string
    {
        $filename = 'finances_' . $userId . '_' . date('YmdHis') . '.csv';
        $path = 'exports/' . $filename;

        $handle = fopen(storage_path('app/public/' . $path), 'w');

        fputcsv($handle, ['Дата', 'Категория', 'Тип', 'Сумма', 'Описание']);

        foreach ($records as $record) {
            fputcsv($handle, [
                Carbon::parse($record->date)->format('Y-m-d'),
                $record->category_name ?? '-',
                $record->type,
                $record->amount,
                $record->description ?? ''
            ]);
        }

        fclose($handle);

        return url('storage/' . $path);
    }

    /**
     * @param array $records
     * @param int $userId
     * @return string
     */
    private function exportToPdf(array $records, int $userId): string
    {
        $filename = 'finances_' . $userId . '_' . date('YmdHis') . '.pdf';
        $path = 'exports/' . $filename;

        $pdf = new FPDF();
        $pdf->AddPage();
        $pdf->SetFont('Arial', 'B', 12);

        $pdf->Cell(40, 10, 'Дата');
        $pdf->Cell(40, 10, 'Категория');
        $pdf->Cell(30, 10, 'Тип');
        $pdf->Cell(30, 10, 'Сумма');
        $pdf->Cell(50, 10, 'Описание');
        $pdf->Ln();

        $pdf->SetFont('Arial', '', 12);
        foreach ($records as $record) {
            $pdf->Cell(40, 10, Carbon::parse($record->date)->format('Y-m-d'));
            $pdf->Cell(40, 10, $record->category_name ?? '-');
            $pdf->Cell(30, 10, $record->type);
            $pdf->Cell(30, 10, $record->amount);
            $pdf->Cell(50, 10, substr($record->description ?? '', 0, 30));
            $pdf->Ln();
        }

        $pdf->Output('F', storage_path('app/public/' . $path));

        return url('storage/' . $path);
    }

    /**
     * @param string $period
     * @param string|null $startDate
     * @param string|null $endDate
     * @return array
     */
    private function getDateRange(string $period, ?string $startDate, ?string $endDate): array
    {
        $now = Carbon::now();

        if ($period === 'custom' && $startDate && $endDate) {
            return [$startDate, $endDate];
        }

        return match ($period) {
            'week'  => [$now->startOfWeek()->format('Y-m-d'), $now->endOfWeek()->format('Y-m-d')],
            'year'  => [$now->startOfYear()->format('Y-m-d'), $now->endOfYear()->format('Y-m-d')],
            default => [$now->startOfMonth()->format('Y-m-d'), $now->endOfMonth()->format('Y-m-d')],
        };
    }
}
