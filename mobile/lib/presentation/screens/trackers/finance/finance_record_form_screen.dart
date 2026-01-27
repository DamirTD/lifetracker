import 'package:flutter/material.dart';
import '../../../../data/models/finance/finance_record.dart';
import '../../../widgets/finance/finance_record_form_widget.dart';

class FinanceRecordFormScreen extends StatelessWidget {
  final FinanceRecord? record;

  const FinanceRecordFormScreen({
    super.key,
    this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: FinanceRecordFormWidget(
            record: record,
            onComplete: (success) {
              if (success) {
                Navigator.pop(context, true);
              }
            },
          ),
        ),
      ),
    );
  }
}