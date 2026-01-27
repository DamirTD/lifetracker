import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/finance/finance_goal.dart';
import '../../providers/finance_provider.dart';

class GoalsWidget extends StatelessWidget {
  const GoalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final goals = provider.goals;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    if (goals.isEmpty) {
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
                  Icons.flag_outlined,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Пока нет целей',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Создайте свою первую финансовую цель\nи начните копить на мечту',
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
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, goal, provider);
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    FinancialGoal goal,
    FinanceProvider provider,
  ) {
    final progressPercentage = goal.progress.clamp(0.0, 100.0);
    final daysRemaining = goal.daysRemaining ?? 0;

    final theme = Theme.of(context);
    final color = _getProgressColor(progressPercentage);
    final currencyFormat = NumberFormat.currency(
      locale: 'kk_KZ',
      symbol: '₸',
      decimalDigits: 0,
    );

    String formatCurrency(double value) => currencyFormat.format(value);

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
                    Icons.flag_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(goal.priority),
                        ],
                      ),
                      if (goal.description != null &&
                          goal.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                value: (progressPercentage / 100).clamp(0.0, 1.0),
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
                      'Прогресс',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Накоплено',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(goal.currentAmount),
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
                      'Цель',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(goal.targetAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'До ${_formatDate(goal.targetDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  daysRemaining > 0
                      ? 'Осталось $daysRemaining дн.'
                      : 'Срок вышел',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: daysRemaining > 0 ? Colors.black87 : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (goal.status == 'active' && progressPercentage < 100)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить прогресс'),
                  onPressed: () =>
                      _showAddProgressDialog(context, goal, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor;
    String label;

    switch (priority) {
      case 'high':
        badgeColor = Colors.red;
        label = 'Высокий';
        break;
      case 'medium':
        badgeColor = Colors.orange;
        label = 'Средний';
        break;
      case 'low':
        badgeColor = Colors.green;
        label = 'Низкий';
        break;
      default:
        badgeColor = Colors.grey;
        label = 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.lightGreen;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else if (percentage >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'ru').format(date);
  }

  void _showAddProgressDialog(
    BuildContext context,
    FinancialGoal goal,
    FinanceProvider provider,
  ) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Добавить прогресс'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Текущая сумма: ${NumberFormat.currency(locale: 'kk_KZ', symbol: '₸', decimalDigits: 0).format(goal.currentAmount)}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Сумма для добавления',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isNotEmpty) {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      // Check for null ID and handle appropriately
                      if (goal.id != null) {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        await provider.updateGoalProgress(goal.id!, amount);

                        navigator.pop();

                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Progress updated for ${goal.name}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Handle case where goal ID is null
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Невозможно обновить цель без ID'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Введите корректную сумму'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Введите сумму'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
