import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardTheme(
      elevation: 2,
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}