import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// Sets up the MaterialApp with theme configuration and initializes the
/// todo screen as the home page. Manages theme mode (light/dark).
class MyApp extends StatefulWidget {
  /// Creates the [MyApp] widget.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Current theme mode (light or dark).
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  /// Loads the saved theme mode from persistent storage.
  Future<void> _loadThemeMode() async {
    final themeMode = await ThemeService.loadThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  /// Toggles between light and dark theme and saves the preference.
  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    ThemeService.saveThemeMode(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: TodoScreen(
        onThemeToggle: _toggleThemeMode,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
