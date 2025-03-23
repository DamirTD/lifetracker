import 'package:flutter/material.dart';
import '../../../widgets/finance/budget_widget.dart';

class FinanceBudgetScreen extends StatelessWidget {
  const FinanceBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BudgetListWidget(),
    );
  }
}