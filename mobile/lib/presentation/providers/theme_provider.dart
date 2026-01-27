import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token') ?? '';
      final isAuthenticated = token.isNotEmpty;

      if (isAuthenticated) {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      } else {
        _isDarkMode = false;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token') ?? '';


    if (token.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    }
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
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      fillColor: Colors.white,
      filled: true,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black87,
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
    cardTheme: CardThemeData(
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
    // Fix for dark theme input fields and text visibility
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      fillColor: const Color(0xFF303030),
      filled: true,
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.grey),
      // Ensuring text is visible against the input background
      prefixIconColor: Colors.grey,
      suffixIconColor: Colors.grey,
    ),
    // Ensuring icons are visible in dark mode
    iconTheme: const IconThemeData(
      color: Colors.white70,
    ),
    // Text theme to ensure text is visible in form fields
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}