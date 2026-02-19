import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/filter_type.dart';
import '../constants/app_constants.dart';
import '../services/todo_service.dart';
import '../widgets/filter_button.dart';
import '../widgets/todo_item.dart';

class TodoScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const TodoScreen({
    required this.onThemeToggle,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [];
  late final TextEditingController _titleController;

  FilterType _currentFilter = FilterType.all;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final loadedTodos = await TodoService.loadTodos();
    setState(() {
      _todos.clear();
      _todos.addAll(loadedTodos);
    });
  }

  Future<void> _saveTodos() async {
    await TodoService.saveTodos(_todos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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

  void _deleteTodo(String todoId) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == todoId);
    });
    _saveTodos();
  }

  void _clearCompletedTodos() {
    setState(() {
      _todos.removeWhere((todo) => todo.isCompleted);
    });
    _saveTodos();
  }

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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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

  int get _activeCount => _todos.where((todo) => !todo.isCompleted).length;

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
          _buildFilterSection(),

          /// 🔥 Animated switch between empty state and list
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: filteredTodos.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: Text(
                        _getEmptyMessage(),
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildTodoList(filteredTodos),
            ),
          ),

          _buildStatsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ✨ Animated List Items
  Widget _buildTodoList(List<Todo> todos) {
    return ListView.builder(
      key: ValueKey(_currentFilter),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: TodoItem(
            todo: todo,
            onToggle: () => _toggleTodoCompletion(todo.id),
            onDelete: () => _deleteTodo(todo.id),
          ),
        );
      },
    );
  }

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

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Text(
        AppConstants.getStatsText(_activeCount, _completedCount),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _showAddTodoModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Todo",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox(); // Required but unused
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeOutBack.transform(animation.value);

        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: curvedValue,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ), // 👈 side padding
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500, // 👈 prevents stretching on large screens
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
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
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: AppConstants.hintText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius,
                                ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
