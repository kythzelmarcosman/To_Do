import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/filter_type.dart';
import '../constants/app_constants.dart';
import '../services/todo_service.dart';
import '../widgets/filter_button.dart';
import '../widgets/todo_item.dart';

/// The main screen of the todo list application.
///
/// Manages todo list state including adding, toggling, deleting, and filtering todos.
class TodoScreen extends StatefulWidget {
  /// Callback to toggle between light and dark theme.
  final VoidCallback onThemeToggle;

  /// Whether the app is currently in dark mode.
  final bool isDarkMode;

  /// Creates a [TodoScreen].
  const TodoScreen({
    required this.onThemeToggle,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  /// The list of all todos.
  final List<Todo> _todos = [];

  /// Controller for the todo input field.
  late final TextEditingController _titleController;

  /// The current active filter.
  FilterType _currentFilter = FilterType.all;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadTodos();
  }

  /// Loads todos from persistent storage.
  Future<void> _loadTodos() async {
    final loadedTodos = await TodoService.loadTodos();
    setState(() {
      _todos.addAll(loadedTodos);
    });
  }

  /// Saves todos to persistent storage.
  Future<void> _saveTodos() async {
    await TodoService.saveTodos(_todos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Adds a new todo to the list.
  ///
  /// Validates that the input is not empty and shows an error if needed.
  void _addTodo() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showErrorSnackBar(AppConstants.emptyInputError);
      return;
    }

    setState(() {
      _todos.add(Todo(id: DateTime.now().toString(), title: title));
    });
    _saveTodos();
    _titleController.clear();
    Navigator.pop(context);
  }

  /// Toggles the completion status of a todo.
  void _toggleTodoCompletion(String todoId) {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      setState(() {
        _todos[index] = _todos[index].copyWith(
          isCompleted: !_todos[index].isCompleted,
        );
      });
      _saveTodos();
    }
  }

  /// Deletes a todo from the list.
  void _deleteTodo(String todoId) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == todoId);
    });
    _saveTodos();
  }

  /// Clears all completed todos from the list.
  void _clearCompletedTodos() {
    setState(() {
      _todos.removeWhere((todo) => todo.isCompleted);
    });
    _saveTodos();
  }

  /// Returns a filtered list of todos based on the current filter.
  List<Todo> _getFilteredTodos() {
    switch (_currentFilter) {
      case FilterType.active:
        return _todos.where((todo) => !todo.isCompleted).toList();
      case FilterType.completed:
        return _todos.where((todo) => todo.isCompleted).toList();
      case FilterType.all:
        return _todos;
    }
  }

  /// Shows an error snack bar with the given message.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Gets the appropriate empty state message based on the current filter.
  String _getEmptyMessage() {
    switch (_currentFilter) {
      case FilterType.all:
        return AppConstants.emptyAllTodos;
      case FilterType.active:
        return AppConstants.emptyActiveTodos;
      case FilterType.completed:
        return AppConstants.emptyCompletedTodos;
    }
  }

  /// Gets the count of active (not completed) todos.
  int get _activeCount => _todos.where((todo) => !todo.isCompleted).length;

  /// Gets the count of completed todos.
  int get _completedCount => _todos.where((todo) => todo.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _getFilteredTodos();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appBarTitle),
        elevation: AppConstants.appBarElevation,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),

          // Empty state or todo list
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Text(
                      _getEmptyMessage(),
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : _buildTodoList(filteredTodos),
          ),

          // Stats and clear completed button
          _buildStatsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows a modal dialog centered on the screen for adding a new todo.
  void _showAddTodoModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a New Todo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppConstants.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.mediumPadding,
                  ),
                ),
                onSubmitted: (_) => _addTodo(),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text(AppConstants.addButtonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the filter button section.
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          FilterButton(
            label: AppConstants.filterAll,
            isActive: _currentFilter == FilterType.all,
            onPressed: () {
              setState(() => _currentFilter = FilterType.all);
            },
          ),
          const SizedBox(width: AppConstants.smallPadding),
          FilterButton(
            label: AppConstants.filterActive,
            isActive: _currentFilter == FilterType.active,
            onPressed: () {
              setState(() => _currentFilter = FilterType.active);
            },
          ),
          const SizedBox(width: AppConstants.smallPadding),
          FilterButton(
            label: AppConstants.filterCompleted,
            isActive: _currentFilter == FilterType.completed,
            onPressed: () {
              setState(() => _currentFilter = FilterType.completed);
            },
          ),

          // Push Clear Completed to the right
          const Spacer(),

          if (_currentFilter == FilterType.completed && _completedCount > 0)
            TextButton.icon(
              onPressed: _clearCompletedTodos,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(AppConstants.clearCompletedLabel),
            ),
        ],
      ),
    );
  }

  /// Builds the todo list view.
  Widget _buildTodoList(List<Todo> todos) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onToggle: () => _toggleTodoCompletion(todo.id),
          onDelete: () => _deleteTodo(todo.id),
        );
      },
    );
  }

  /// Builds the stats section showing counts.
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Text(
        AppConstants.getStatsText(_activeCount, _completedCount),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
