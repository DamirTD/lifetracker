import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../data/models/finance/finance_summary.dart';
import '../../../providers/finance_provider.dart';
import 'finance_records_screen.dart';

class FinanceDashboardWidget extends StatefulWidget {
  const FinanceDashboardWidget({super.key});

  @override
  State<FinanceDashboardWidget> createState() => _FinanceDashboardWidgetState();
}

class _FinanceDashboardWidgetState extends State<FinanceDashboardWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final summary = provider.summary;
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
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(context, provider),
            const SizedBox(height: 24),

            // Summary Card with Circular Chart
            if (summary != null) _buildSummaryCard(context, summary),

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
      elevation: 8,
      shadowColor: theme.colorScheme.primary.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withAlpha(200),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Финансовый обзор',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Анализ ваших финансов',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Circular Chart Section
              _buildCircularChart(context, summary, formatter),

              const SizedBox(height: 32),

              // Legend
              _buildChartLegend(context, summary, formatter),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularChart(
    BuildContext context,
    FinanceSummary summary,
    NumberFormat formatter,
  ) {
    final theme = Theme.of(context);

    final total =
        summary.totalIncome +
        summary.totalExpense +
        summary.totalSaving +
        summary.totalInvestment;

    if (total == 0) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
              ),
            ),

            // Custom Circular Chart
            CustomPaint(
              size: const Size(260, 260),
              painter: CircularChartPainter(
                income: summary.totalIncome,
                expense: summary.totalExpense,
                saving: summary.totalSaving,
                investment: summary.totalInvestment,
                total: total,
              ),
            ),

            // Center content
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Общий',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                  Text(
                    formatter.format(total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(
    BuildContext context,
    FinanceSummary summary,
    NumberFormat formatter,
  ) {
    final theme = Theme.of(context);

    final items = [
      _LegendItem(
        'Доходы',
        summary.totalIncome,
        Colors.green,
        Icons.arrow_downward,
        'income',
      ),
      _LegendItem(
        'Расходы',
        summary.totalExpense,
        Colors.red,
        Icons.arrow_upward,
        'expense',
      ),
      _LegendItem(
        'Накопления',
        summary.totalSaving,
        Colors.blue,
        Icons.savings,
        'saving',
      ),
      _LegendItem(
        'Инвестиции',
        summary.totalInvestment,
        Colors.purple,
        Icons.trending_up,
        'investment',
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLegendCard(context, items[0], formatter)),
            const SizedBox(width: 12),
            Expanded(child: _buildLegendCard(context, items[1], formatter)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLegendCard(context, items[2], formatter)),
            const SizedBox(width: 12),
            Expanded(child: _buildLegendCard(context, items[3], formatter)),
          ],
        ),

        // Saving Rate
        if (summary.savingRate != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(100),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.percent,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Процент накоплений',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: summary.savingRate! / 100,
                          backgroundColor: theme.colorScheme.outline.withAlpha(
                            50,
                          ),
                          color: theme.colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${summary.savingRate!.toStringAsFixed(1)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendCard(
    BuildContext context,
    _LegendItem item,
    NumberFormat formatter,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Переход к экрану транзакций с нужным типом
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FinanceRecordsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withAlpha(100), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(item.icon, color: item.color, size: 20),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatter.format(item.value),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Смотреть операции',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: item.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, FinanceProvider provider) {
    final theme = Theme.of(context);
    final periods = [
      {'value': 'day', 'label': 'День', 'icon': Icons.today},
      {'value': 'week', 'label': 'Неделя', 'icon': Icons.date_range},
      {'value': 'month', 'label': 'Месяц', 'icon': Icons.calendar_month},
      {'value': 'year', 'label': 'Год', 'icon': Icons.calendar_today},
    ];

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(50),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Период отображения',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    periods.map((period) {
                      final isSelected =
                          provider.currentPeriod == period['value'];
                      return GestureDetector(
                        onTap: () {
                          provider.getFinanceRecords(
                            period: period['value'] as String,
                            type: provider.currentType,
                            startDate: provider.startDate,
                            endDate: provider.endDate,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withAlpha(
                                        100,
                                      ),
                              width: 1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withAlpha(50),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                period['icon'] as IconData,
                                size: 18,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                period['label'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _LegendItem {
  final String title;
  final double value;
  final Color color;
  final IconData icon;
  final String type;

  _LegendItem(this.title, this.value, this.color, this.icon, this.type);
}

class CircularChartPainter extends CustomPainter {
  final double income;
  final double expense;
  final double saving;
  final double investment;
  final double total;

  CircularChartPainter({
    required this.income,
    required this.expense,
    required this.saving,
    required this.investment,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 30.0;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // Income
    if (income > 0) {
      final sweepAngle = (income / total) * 2 * math.pi;
      paint.color = Colors.green;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Expense
    if (expense > 0) {
      final sweepAngle = (expense / total) * 2 * math.pi;
      paint.color = Colors.red;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Saving
    if (saving > 0) {
      final sweepAngle = (saving / total) * 2 * math.pi;
      paint.color = Colors.blue;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Investment
    if (investment > 0) {
      final sweepAngle = (investment / total) * 2 * math.pi;
      paint.color = Colors.purple;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
