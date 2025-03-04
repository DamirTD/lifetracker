import 'package:flutter/material.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сон')),
      body: const Center(child: Text('Экран сна')),
    );
  }
}
