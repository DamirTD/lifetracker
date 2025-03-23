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
      appBar: AppBar(
        title: Text(record == null ? 'Add Record' : 'Edit Record'),
      ),
      body: FinanceRecordFormWidget(
        record: record,
        onComplete: (success) {
          if (success) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}