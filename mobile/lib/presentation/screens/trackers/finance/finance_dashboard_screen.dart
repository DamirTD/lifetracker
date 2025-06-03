import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/finance/finance_summary.dart';
import '../../../../data/models/finance/financial_advice.dart';
import '../../../providers/finance_provider.dart';

class FinanceDashboardWidget extends StatelessWidget {
  const FinanceDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final summary = provider.summary;
    final advice = provider.advice;
    final theme = Theme.of(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки данных',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
              onPressed: () {
                provider.getFinanceRecords(period: 'month');
                provider.getFinancialAdvice();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.getFinanceRecords(period: 'month');
        await provider.getFinancialAdvice();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(context, provider),
            const SizedBox(height: 16),

            // Summary Card
            if (summary != null) _buildSummaryCard(context, summary),

            const SizedBox(height: 24),

            // Financial Advice
            if (advice.isNotEmpty) _buildAdviceSection(context, advice),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, FinanceSummary summary) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: 'kk_KZ', symbol: '₸');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Финансовый обзор',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryItem(
              context,
              'Доходы',
              formatter.format(summary.totalIncome),
              Icons.arrow_downward,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Расходы',
              formatter.format(summary.totalExpense),
              Icons.arrow_upward,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Накопления',
              formatter.format(summary.totalSaving),
              Icons.savings,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Инвестиции',
              formatter.format(summary.totalInvestment),
              Icons.trending_up,
              Colors.purple,
            ),
            if (summary.savingRate != null) ...[
              const SizedBox(height: 24),
              Text(
                'Процент накоплений',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.savingRate! / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: theme.colorScheme.primary,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${summary.savingRate!.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30), // вместо withOpacity
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, FinanceProvider provider) {
    final theme = Theme.of(context);
    final types = ['all', 'income', 'expense', 'saving', 'investment'];
    final periods = ['day', 'week', 'month', 'year'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Фильтр', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: provider.currentPeriod,
                    decoration: const InputDecoration(labelText: 'Период'),
                    items:
                        periods
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      provider.getFinanceRecords(
                        period: value,
                        type: provider.currentType,
                        startDate: provider.startDate,
                        endDate: provider.endDate,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: provider.currentType,
                    decoration: const InputDecoration(labelText: 'Тип'),
                    items:
                        types
                            .map(
                              (e) => DropdownMenuItem(
                                value: e == 'all' ? null : e,
                                child: Text(e == 'all' ? 'Все' : e),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      provider.getFinanceRecords(
                        period: provider.currentPeriod,
                        type: value,
                        startDate: provider.startDate,
                        endDate: provider.endDate,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      provider.startDate != null
                          ? DateFormat('dd.MM.yyyy').format(provider.startDate!)
                          : 'С даты',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        provider.getFinanceRecords(
                          period: provider.currentPeriod,
                          type: provider.currentType,
                          startDate: date,
                          endDate: provider.endDate,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event),
                    label: Text(
                      provider.endDate != null
                          ? DateFormat('dd.MM.yyyy').format(provider.endDate!)
                          : 'По дату',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        provider.getFinanceRecords(
                          period: provider.currentPeriod,
                          type: provider.currentType,
                          startDate: provider.startDate,
                          endDate: date,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection(
    BuildContext context,
    List<FinancialAdvice> advice,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Финансовые советы',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...advice.map((item) => _buildAdviceCard(context, item)),
      ],
    );
  }

  Widget _buildAdviceCard(BuildContext context, FinancialAdvice advice) {
    final theme = Theme.of(context);
    final (color, icon) = _getAdviceStyle(advice.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha((0.1 * 255).round()),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Можно добавить детальное описание по тапу
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advice.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      advice.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (0.7 * 255).round(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (advice.action != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          advice.action!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, IconData) _getAdviceStyle(String type) {
    switch (type.toLowerCase()) {
      case 'saving':
        return (Colors.blue, Icons.savings);
      case 'expense':
        return (Colors.red, Icons.money_off);
      case 'investment':
        return (Colors.purple, Icons.trending_up);
      case 'income':
        return (Colors.green, Icons.payments);
      default:
        return (Colors.grey, Icons.info);
    }
  }
}
