import 'package:flutter/material.dart';
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
        return const Center(
          child: Text('No budgets found. Create your first budget!'),
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
      final categoryName = budget.categoryName ?? 'Unknown Category';
      final period = budget.period;

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    period.capitalize(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentageUsed / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getBudgetColor(percentageUsed),
                ),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${percentageUsed.toStringAsFixed(1)}% used'),
                  Text('\$${spent.toStringAsFixed(2)} / \$${amount.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining: \$${remaining.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (budget.startDate != null && budget.endDate != null)
                    Text(
                      '${_formatDate(budget.startDate!)} - ${_formatDate(budget.endDate!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}