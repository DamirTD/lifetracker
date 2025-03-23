import 'package:flutter/material.dart';
import '../../../widgets/finance/goals_widget.dart';

class FinanceGoalsScreen extends StatelessWidget {
  const FinanceGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GoalsWidget(),
    );
  }
}