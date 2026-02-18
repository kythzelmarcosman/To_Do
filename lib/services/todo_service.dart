import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

/// Service for persisting todos to local storage.
///
/// Handles saving and loading todos using SharedPreferences.
class TodoService {
  static const String _todosKey = 'todos';

  /// Loads all todos from persistent storage.
  ///
  /// Returns an empty list if no todos are found.
  static Future<List<Todo>> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList(_todosKey) ?? [];

      return todosJson.map((json) => _todoFromJson(json)).toList();
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }

  /// Saves all todos to persistent storage.
  static Future<void> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = todos.map((todo) => _todoToJson(todo)).toList();
      await prefs.setStringList(_todosKey, todosJson);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  /// Converts a Todo object to a JSON string.
  static String _todoToJson(Todo todo) {
    return jsonEncode({
      'id': todo.id,
      'title': todo.title,
      'isCompleted': todo.isCompleted,
      'createdAt': todo.createdAt.toIso8601String(),
    });
  }

  /// Converts a JSON string back to a Todo object.
  static Todo _todoFromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return Todo(
      id: data['id'] as String,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
