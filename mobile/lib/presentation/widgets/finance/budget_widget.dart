import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/finance/finance_budget.dart';
import '../../providers/finance_provider.dart';

  class BudgetListWidget extends StatelessWidget {
    const BudgetListWidget({super.key});

    @override
    Widget build(BuildContext context) {
      final provider = Provider.of<FinanceProvider>(context);
      final budgets = provider.budgets;

      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (provider.error != null) {
        return Center(child: Text('Error: ${provider.error}'));
      }

      if (budgets.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Пока нет бюджетов',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Создайте свой первый бюджет\nи начните контролировать расходы',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return _buildBudgetCard(budget);
        },
      );
    }

    Widget _buildBudgetCard(Budget budget) {
      final percentageUsed = (budget.percentageUsed).clamp(0.0, 100.0);
      final amount = budget.amount;
      final spent = budget.spent;
      final remaining = budget.remaining;
      final categoryName = budget.categoryName ?? 'Без категории';
      final period = budget.period;

      final color = _getBudgetColor(percentageUsed);
      final currencyFormat = NumberFormat.currency(
        locale: 'kk_KZ',
        symbol: '₸',
        decimalDigits: 0,
      );

      String formatCurrency(double value) => currencyFormat.format(value);

      String _periodLabel(String p) {
        switch (p) {
          case 'day':
            return 'День';
          case 'week':
            return 'Неделя';
          case 'month':
            return 'Месяц';
          case 'year':
            return 'Год';
          default:
            return 'Период';
        }
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.10),
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: color.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _periodLabel(period),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${percentageUsed.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (percentageUsed / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.7),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Лимит',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(amount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Потрачено',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(spent),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Осталось',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(remaining),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: remaining <= 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (budget.startDate != null && budget.endDate != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(budget.startDate!)} — ${_formatDate(budget.endDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

  Color _getBudgetColor(double percentage) {
    if (percentage >= 100) {
      return Colors.red;
    } else if (percentage >= 75) {
      return Colors.orange;
    } else if (percentage >= 50) {
      return Colors.yellow.shade700;
    } else {
      return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'ru').format(date);
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}