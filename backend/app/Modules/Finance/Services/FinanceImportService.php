<?php

namespace App\Modules\Finance\Services;

use App\Models\FinanceCategory;
use App\Modules\Finance\ServiceInterfaces\FinanceImportServiceInterface;
use App\Models\FinanceRecord;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\IOFactory;

class FinanceImportService implements FinanceImportServiceInterface
{
    /**
     * @param int $userId
     * @param UploadedFile $file
     * @return int Number of imported records
     * @throws \Exception
     */
    public function import(
        int $userId,
        UploadedFile $file
    ): int {
        $extension = $file->getClientOriginalExtension();

        return match ($extension) {
            'xlsx', 'xls' => $this->importFromExcel($userId, $file),
            'csv'         => $this->importFromCsv($userId, $file),
            default       => throw new \Exception('Неподдерживаемый формат файла.'),
        };
    }

    /**
     * @param int $userId
     * @param UploadedFile $file
     * @return int
     * @throws \Exception
     */
    private function importFromExcel(int $userId, UploadedFile $file): int
    {
        $spreadsheet = IOFactory::load($file->getRealPath());
        $worksheet = $spreadsheet->getActiveSheet();
        $rows = $worksheet->toArray();

        // Первая строка - заголовки
        $headers = array_shift($rows);

        return $this->processImportData($userId, $headers, $rows);
    }

    /**
     * @param int $userId
     * @param UploadedFile $file
     * @return int
     * @throws \Exception
     */
    private function importFromCsv(int $userId, UploadedFile $file): int
    {
        $handle = fopen($file->getRealPath(), 'r');

        $headers = fgetcsv($handle);

        $rows = [];
        while (($data = fgetcsv($handle)) !== false) {
            $rows[] = $data;
        }

        fclose($handle);

        return $this->processImportData($userId, $headers, $rows);
    }

    /**
     * @param int $userId
     * @param array $headers
     * @param array $rows
     * @return int
     * @throws \Exception
     */
    private function processImportData(int $userId, array $headers, array $rows): int
    {
        $headerMap = $this->normalizeHeaders($headers);

        $categories = FinanceCategory::where('user_id', $userId)->get()->keyBy('name');

        $importedCount = 0;

        DB::beginTransaction();

        try {
            foreach ($rows as $row) {
                if (count($row) !== count($headers)) {
                    continue;
                }

                $data = array_combine($headerMap, $row);

                if (empty($data['amount']) || empty($data['type']) || empty($data['date'])) {
                    continue;
                }

                $categoryName = $data['category'] ?? 'Без категории';
                $categoryType = $data['type'];

                if (!isset($categories[$categoryName])) {
                    $category = FinanceCategory::create([
                        'user_id' => $userId,
                        'name' => $categoryName,
                        'type' => $categoryType
                    ]);
                    $categories[$categoryName] = $category;
                }

                FinanceRecord::create([
                    'user_id'     => $userId,
                    'category_id' => $categories[$categoryName]->id,
                    'amount'      => floatval($data['amount']),
                    'type'        => $data['type'],
                    'period'      => $data['period'] ?? 'month',
                    'date'        => $data['date'],
                    'description' => $data['description'] ?? null
                ]);

                $importedCount++;
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }

        return $importedCount;
    }

    /**
     * @param array $headers
     * @return array
     */
    private function normalizeHeaders(array $headers): array
    {
        $result = [];

        $mapping = [
            'дата'        => 'date',
            'date'        => 'date',
            'категория'   => 'category',
            'category'    => 'category',
            'тип'         => 'type',
            'type'        => 'type',
            'сумма'       => 'amount',
            'amount'      => 'amount',
            'описание'    => 'description',
            'description' => 'description',
            'период'      => 'period',
            'period'      => 'period'
        ];

        foreach ($headers as $index => $header) {
            $header = mb_strtolower(trim($header));
            $result[$index] = $mapping[$header] ?? $header;
        }

        return $result;
    }
}
