import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;
  double _fontSize = 20.0; // Default font size

  // Define light and dark themes with dynamic font size
  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.green,
      appBarTheme: AppBarTheme(
        color: Colors.green, // Set AppBar color for both themes
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        bodyMedium: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        bodySmall: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        headlineLarge: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        headlineMedium: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        headlineSmall: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'Quran', // Apply font family here
        ),
        // Add more styles if needed
      ),
    );
  }

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  void increaseFontSize() {
    _fontSize += 2.0; // Increase font size by 2
    notifyListeners();
  }

  void decreaseFontSize() {
    if (_fontSize > 10.0) { // Ensure font size doesn't get too small
      _fontSize -= 2.0; // Decrease font size by 2
      notifyListeners();
    }
  }
}
