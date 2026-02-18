import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App metadata
  static const String appTitle = 'Todo List';
  static const String appBarTitle = 'My Todo List';

  // UI Strings
  static const String hintText = 'Add a new todo...';
  static const String addButtonLabel = 'Add';
  static const String clearCompletedLabel = 'Clear';
  static const String emptyAllTodos = 'No todos yet. Add one to get started!';
  static const String emptyActiveTodos = 'No active todos yet.';
  static const String emptyCompletedTodos = 'No completed todos yet.';
  static const String emptyInputError = 'Please enter a todo';

  // Spacing and sizing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double borderRadius = 8.0;
  static const double appBarElevation = 0.0;

  // Theme
  static const Color seedColor = Colors.blue;
  static const bool useMaterial3 = true;

  // Filter labels
  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterCompleted = 'Completed';

  // Stats text
  static String getStatsText(int activeCount, int completedCount) {
    return '$activeCount active, $completedCount completed';
  }
}
