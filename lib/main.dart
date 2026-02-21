import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/task_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'models/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TodoAdapter());

  await Hive.openBox<Task>('tasks');
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
      home: TaskScreen(onThemeToggle: _toggleThemeMode),
    );
  }
}
