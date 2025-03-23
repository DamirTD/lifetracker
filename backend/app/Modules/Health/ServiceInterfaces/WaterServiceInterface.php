<?php

namespace App\Modules\Health\ServiceInterfaces;

use App\Modules\Health\DTO\WaterContainerDTO;
use App\Modules\Health\DTO\WaterGoalDTO;
use App\Modules\Health\DTO\WaterReminderDTO;

interface WaterServiceInterface
{
    /**
     * Расчет и установка дневной нормы потребления воды
     */
    public function calculateDailyGoal(WaterGoalDTO $data): array;

    /**
     * Добавление стакана воды
     */
    public function addGlass(int $userId, ?int $containerId = null, ?int $customVolumeMl = null): array;

    /**
     * Удаление последнего добавленного стакана воды
     */
    public function removeGlass(int $userId): array;

    /**
     * Получение статистики за день
     */
    public function getDailyStats(int $userId): array;

    /**
     * Получение общей статистики по потреблению воды
     */
    public function getOverallStats(int $userId): array;

    /**
     * Получение данных о потреблении за день
     */
    public function getDailyConsumption(int $userId, ?string $date = null): array;

    /**
     * Получение данных о потреблении за неделю
     */
    public function getWeeklyConsumption(int $userId, ?string $startDate = null): array;

    /**
     * Получение данных о потреблении за месяц
     */
    public function getMonthlyConsumption(int $userId, ?string $yearMonth = null): array;

    /**
     * Получение истории потребления воды
     */
    public function getHistory(int $userId, ?string $startDate = null, ?string $endDate = null, int $perPage = 10): array;

    /**
     * Сохранение пользовательского контейнера для воды
     */
    public function saveContainer(int $userId, WaterContainerDTO $containerData): array;

    /**
     * Получение всех контейнеров пользователя
     */
    public function getContainers(int $userId): array;

    /**
     * Удаление контейнера пользователя
     */
    public function deleteContainer(int $userId, int $containerId): array;

    /**
     * Установка напоминания о питье воды
     */
    public function setReminder(int $userId, WaterReminderDTO $reminderData): array;

    /**
     * Получение всех напоминаний пользователя
     */
    public function getReminders(int $userId): array;

    /**
     * Удаление напоминания пользователя
     */
    public function deleteReminder(int $userId, int $reminderId): array;

    /**
     * Включение/выключение напоминания
     */
    public function toggleReminder(int $userId, int $reminderId, bool $isEnabled): array;

    /**
     * Получение аналитических рекомендаций по потреблению воды
     */
    public function getConsumptionInsights(int $userId): array;

    /**
     * Сравнение потребления воды с другими пользователями
     */
    public function getComparison(int $userId): array;

    /**
     * Получение экологического отчета о сохранении пластика
     */
    public function getEcoReport(int $userId): array;
}
