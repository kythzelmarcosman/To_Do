import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../constants/app_constants.dart';

/// A widget that displays a single todo item in the list.
///
/// Shows the todo's completion status via checkbox, title with strikethrough
/// for completed items, and a delete button.
class TodoItem extends StatelessWidget {
  /// The todo data to display.
  final Todo todo;

  /// Callback when the todo's completion status is toggled.
  final VoidCallback onToggle;

  /// Callback when the todo is deleted.
  final VoidCallback onDelete;

  /// Creates a [TodoItem].
  const TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final completedColor = isDarkMode ? Colors.grey.shade600 : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? completedColor : textColor,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
