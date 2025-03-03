import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
