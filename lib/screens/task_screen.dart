import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Add uuid: ^4.0.0 to pubspec.yaml
import '../models/task.dart';
import '../models/todo.dart';
import '../services/task_service.dart';

class TaskScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const TaskScreen({super.key, required this.onThemeToggle});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _taskFocusNode = FocusNode();

  final Map<String, TextEditingController> _todoControllers = {};
  final Map<String, FocusNode> _todoFocusNodes = {};

  // Tracks which task cards are currently expanded
  final Set<String> _expandedTasks = {};

  // True whenever any todo input field has focus
  bool _todoFieldFocused = false;

  final _uuid = const Uuid();

  // Returns a controller for the given task ID, creating one if needed.
  TextEditingController _controllerFor(String taskId) {
    return _todoControllers.putIfAbsent(taskId, () => TextEditingController());
  }

  // Returns a FocusNode for the given task ID, creating one if needed.
  // Each node updates _todoFieldFocused when its focus changes.
  FocusNode _focusNodeFor(String taskId) {
    return _todoFocusNodes.putIfAbsent(taskId, () {
      final node = FocusNode();
      node.addListener(() {
        final anyFocused = _todoFocusNodes.values.any((n) => n.hasFocus);
        if (anyFocused != _todoFieldFocused) {
          setState(() => _todoFieldFocused = anyFocused);
        }
      });
      return node;
    });
  }

  // Removes and disposes controllers/nodes for tasks that no longer exist.
  void _pruneControllers(List<Task> currentTasks) {
    final currentIds = currentTasks.map((t) => t.id).toSet();
    final staleIds = _todoControllers.keys
        .where((id) => !currentIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _todoControllers.remove(id)?.dispose();
      _todoFocusNodes.remove(id)?.dispose();
    }
    _expandedTasks.removeWhere((id) => !currentIds.contains(id));
  }

  @override
  void dispose() {
    _taskController.dispose();
    _taskFocusNode.dispose();
    for (final c in _todoControllers.values) {
      c.dispose();
    }
    for (final n in _todoFocusNodes.values) {
      n.dispose();
    }
    _todoControllers.clear();
    _todoFocusNodes.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasks');
    final theme = Theme.of(context);
    final cardBorderColor = theme.colorScheme.primary.withOpacity(0.3);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final inputBackground = theme.scaffoldBackgroundColor;
    final iconColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            /// TASK LIST
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Task> box, _) {
                  final tasks = box.values.toList();

                  _pruneControllers(tasks);

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        "No tasks yet",
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isExpanded = _expandedTasks.contains(task.id);

                      // Progress calculation
                      final totalTodos = task.todos.length;
                      final completedTodos = task.todos
                          .where((t) => t.isCompleted)
                          .length;
                      final progress = totalTodos == 0
                          ? 0.0
                          : completedTodos / totalTodos;
                      final allDone =
                          totalTodos > 0 && completedTodos == totalTodos;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: cardBorderColor),
                        ),
                        child: Slidable(
                          key: Key(task.id),
                          enabled: !isExpanded,
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) => TaskService.deleteTask(task),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            minTileHeight: 65,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _expandedTasks.add(task.id);
                                } else {
                                  _expandedTasks.remove(task.id);
                                  // Unfocus the todo field when tile collapses
                                  _todoFocusNodes[task.id]?.unfocus();
                                }
                              });
                            },
                            title: Text(
                              task.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: allDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            // Circular progress indicator with count in centre
                            trailing: SizedBox(
                              width: 35,
                              height: 35,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: 1,
                                    strokeWidth: 4,
                                    color: iconColor.withOpacity(0.15),
                                  ),
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 4,
                                    color: iconColor,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  Center(
                                    child: Text(
                                      totalTodos == 0
                                          ? '—'
                                          : '$completedTodos/$totalTodos',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontSize: totalTodos >= 10 ? 8 : 10,
                                            fontWeight: FontWeight.bold,
                                            color: allDone
                                                ? iconColor
                                                : textColor.withOpacity(0.7),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              // 1️⃣ Show all todos
                              ...(List<Todo>.from(task.todos)..sort(
                                    (a, b) => a.isCompleted == b.isCompleted
                                        ? 0
                                        : a.isCompleted
                                        ? 1
                                        : -1,
                                  ))
                                  .map((todo) {
                                    return Slidable(
                                      key: Key(todo.id),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.20,
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) =>
                                                TaskService.deleteTodo(
                                                  task,
                                                  todo,
                                                ),
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete_outline,
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: todo.isCompleted,
                                          onChanged: (_) =>
                                              TaskService.toggleTodo(
                                                task,
                                                todo,
                                              ),
                                          activeColor: iconColor,
                                        ),
                                        title: Text(
                                          todo.title,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                decoration: todo.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                        ),
                                      ),
                                    );
                                  }),

                              // 2️⃣ Add todo input field
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _controllerFor(task.id),
                                  focusNode: _focusNodeFor(task.id),
                                  decoration: InputDecoration(
                                    hintText: 'Add todo...',
                                    hintStyle: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: textColor.withOpacity(0.6),
                                        ),
                                    filled: true,
                                    fillColor: inputBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: cardBorderColor,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.add, color: iconColor),
                                      onPressed: () {
                                        final controller = _controllerFor(
                                          task.id,
                                        );
                                        final text = controller.text.trim();
                                        if (text.isEmpty) return;

                                        final todo = Todo(
                                          id: _uuid.v4(),
                                          title: text,
                                        );
                                        TaskService.addTodo(task, todo);
                                        controller.clear();
                                        // Unfocus after adding
                                        _todoFocusNodes[task.id]?.unfocus();
                                      },
                                    ),
                                  ),
                                  onSubmitted: (text) {
                                    final trimmed = text.trim();
                                    if (trimmed.isEmpty) return;

                                    final todo = Todo(
                                      id: _uuid.v4(),
                                      title: trimmed,
                                    );
                                    TaskService.addTodo(task, todo);
                                    _controllerFor(task.id).clear();
                                    // Unfocus after submitting via keyboard
                                    _todoFocusNodes[task.id]?.unfocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// FLOATING ADD TASK FIELD — hidden while a todo field is focused
            if (!_todoFieldFocused)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.grey.shade900,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _taskController,
                            focusNode: _taskFocusNode,
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Add new task...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium!.color!
                                    .withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (text) {
                              final trimmed = text.trim();
                              if (trimmed.isEmpty) return;
                              TaskService.addTask(
                                Task(id: _uuid.v4(), title: trimmed, todos: []),
                              );
                              _taskController.clear();
                              // Unfocus after submitting via keyboard
                              _taskFocusNode.unfocus();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: theme.colorScheme.primary),
                        onPressed: () {
                          if (_taskController.text.trim().isEmpty) return;
                          TaskService.addTask(
                            Task(
                              id: _uuid.v4(),
                              title: _taskController.text.trim(),
                              todos: [],
                            ),
                          );
                          _taskController.clear();
                          // Unfocus after adding
                          _taskFocusNode.unfocus();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
