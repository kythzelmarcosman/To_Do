import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/todo.dart';

class TaskService {
  static const String _boxName = 'tasks';

  /// Get the task box
  static Box<Task> _taskBox() => Hive.box<Task>(_boxName);

  /// Load all tasks
  static List<Task> loadTasks() {
    return _taskBox().values.toList();
  }

  /// Add new task
  static Future<void> addTask(Task task) async {
    await _taskBox().add(task);
  }

  /// Delete task
  static Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  /// Add todo inside a task
  static Future<void> addTodo(Task task, Todo todo) async {
    task.todos.add(todo);
    await task.save();
  }

  /// Toggle todo completion
  static Future<void> toggleTodo(Task task, Todo todo) async {
    todo.isCompleted = !todo.isCompleted;

    // Auto-update task completion status
    task.isCompleted =
        task.todos.isNotEmpty && task.todos.every((t) => t.isCompleted);

    await task.save();
  }

  /// Toggle entire task completion
  static Future<void> toggleTask(Task task) async {
    task.isCompleted = !task.isCompleted;

    for (var todo in task.todos) {
      todo.isCompleted = task.isCompleted;
    }

    await task.save();
  }

  /// Delete a todo from a task
  static void deleteTodo(Task task, Todo todo) {
    task.todos.removeWhere((t) => t.id == todo.id);
    task.save(); // saves the change to Hive
  }
}
