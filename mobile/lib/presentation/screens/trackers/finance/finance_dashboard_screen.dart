import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.getFinanceRecords(period: 'month');
                provider.getFinancialAdvice();
              },
              child: const Text('Retry'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            if (summary != null) _buildSummaryCard(context, summary),

            const SizedBox(height: 16),

            // Recent Transactions (can be implemented if needed)

            const SizedBox(height: 16),

            // Financial Advice
            if (advice.isNotEmpty)
              _buildAdviceSection(context, advice),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, FinanceSummary summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem('Income', summary.totalIncome, Icons.arrow_downward, Colors.green),
            const SizedBox(height: 8),
            _buildSummaryItem('Expenses', summary.totalExpense, Icons.arrow_upward, Colors.red),
            const SizedBox(height: 8),
            _buildSummaryItem('Savings', summary.totalSaving, Icons.savings, Colors.blue),
            const SizedBox(height: 8),
            _buildSummaryItem('Investments', summary.totalInvestment, Icons.trending_up, Colors.purple),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${summary.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: summary.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (summary.savingRate != null) ...[
              const SizedBox(height: 8),
              Text('Saving Rate: ${summary.savingRate!.toStringAsFixed(1)}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1 * 255),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceSection(BuildContext context, List<FinancialAdvice> advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Advice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...advice.map((item) => _buildAdviceCard(context, item)),
      ],
    );
  }

  Widget _buildAdviceCard(BuildContext context, FinancialAdvice advice) {
    Color cardColor;
    IconData cardIcon;

    // Determine color and icon based on advice type
    switch (advice.type.toLowerCase()) {
      case 'saving':
        cardColor = Colors.blue;
        cardIcon = Icons.savings;
        break;
      case 'expense':
        cardColor = Colors.red;
        cardIcon = Icons.money_off;
        break;
      case 'investment':
        cardColor = Colors.purple;
        cardIcon = Icons.trending_up;
        break;
      case 'income':
        cardColor = Colors.green;
        cardIcon = Icons.payments;
        break;
      default:
        cardColor = Colors.grey;
        cardIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cardColor.withValues(alpha: 0.3 * 255)),

      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1 * 255),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(cardIcon, color: cardColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advice.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advice.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}