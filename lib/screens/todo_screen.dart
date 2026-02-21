// import 'package:flutter/material.dart';
// import '../models/todo.dart';
// import '../models/filter_type.dart';
// import '../constants/app_constants.dart';
// import '../services/todo_service.dart';
// import '../widgets/filter_button.dart';
// import '../widgets/todo_item.dart';

// class TodoScreen extends StatefulWidget {
//   final VoidCallback onThemeToggle;
//   final bool isDarkMode;

//   const TodoScreen({
//     required this.onThemeToggle,
//     required this.isDarkMode,
//     super.key,
//   });

//   @override
//   State<TodoScreen> createState() => _TodoScreenState();
// }

// class _TodoScreenState extends State<TodoScreen> {
//   final List<Todo> _todos = [];
//   late final TextEditingController _titleController;

//   FilterType _currentFilter = FilterType.all;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController();
//     _loadTodos();
//   }

//   Future<void> _loadTodos() async {
//     final loadedTodos = await TodoService.loadTodos();
//     setState(() {
//       _todos.clear();
//       _todos.addAll(loadedTodos);
//     });
//   }

//   Future<void> _saveTodos() async {
//     await TodoService.saveTodos(_todos);
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   void _addTodo() {
//     final title = _titleController.text.trim();
//     if (title.isEmpty) {
//       _showErrorSnackBar(AppConstants.emptyInputError);
//       return;
//     }

//     setState(() {
//       _todos.add(Todo(id: DateTime.now().toString(), title: title));
//     });

//     _saveTodos();
//     _titleController.clear();

//     // Remove focus from TextField
//     FocusScope.of(context).unfocus();
//   }

//   void _toggleTodoCompletion(String todoId) {
//     final index = _todos.indexWhere((todo) => todo.id == todoId);
//     if (index != -1) {
//       setState(() {
//         _todos[index] = _todos[index].copyWith(
//           isCompleted: !_todos[index].isCompleted,
//         );
//       });
//       _saveTodos();
//     }
//   }

//   void _deleteTodo(String todoId) {
//     setState(() {
//       _todos.removeWhere((todo) => todo.id == todoId);
//     });
//     _saveTodos();
//   }

//   // void _clearCompletedTodos() {
//   //   setState(() {
//   //     _todos.removeWhere((todo) => todo.isCompleted);
//   //   });
//   //   _saveTodos();
//   // }

//   List<Todo> _getFilteredTodos() {
//     switch (_currentFilter) {
//       case FilterType.active:
//         return _todos.where((todo) => !todo.isCompleted).toList();
//       case FilterType.completed:
//         return _todos.where((todo) => todo.isCompleted).toList();
//       case FilterType.all:
//         return _todos;
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   String _getEmptyMessage() {
//     switch (_currentFilter) {
//       case FilterType.all:
//         return AppConstants.emptyAllTodos;
//       case FilterType.active:
//         return AppConstants.emptyActiveTodos;
//       case FilterType.completed:
//         return AppConstants.emptyCompletedTodos;
//     }
//   }

//   int get _activeCount => _todos.where((todo) => !todo.isCompleted).length;
//   int get _completedCount => _todos.where((todo) => todo.isCompleted).length;

//   @override
//   Widget build(BuildContext context) {
//     final filteredTodos = _getFilteredTodos();
//     final textTheme = Theme.of(context).textTheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(AppConstants.appBarTitle),
//         elevation: AppConstants.appBarElevation,
//         actions: [
//           IconButton(
//             icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
//             onPressed: widget.onThemeToggle,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilterSection(),

//           /// 🔥 Animated switch between empty state and list
//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, animation) {
//                 return FadeTransition(
//                   opacity: animation,
//                   child: SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0.05, 0),
//                       end: Offset.zero,
//                     ).animate(animation),
//                     child: child,
//                   ),
//                 );
//               },
//               child: filteredTodos.isEmpty
//                   ? Center(
//                       key: const ValueKey('empty'),
//                       child: Text(
//                         _getEmptyMessage(),
//                         style: textTheme.bodyLarge,
//                         textAlign: TextAlign.center,
//                       ),
//                     )
//                   : _buildTodoList(filteredTodos),
//             ),
//           ),

//           _buildStatsSection(),

//           /// Bottom minimal add-todo bar
//           _buildAddTodoBar(),
//         ],
//       ),
//     );
//   }

//   /// ✨ Animated List Items
//   Widget _buildTodoList(List<Todo> todos) {
//     return ListView.builder(
//       key: ValueKey(_currentFilter),
//       itemCount: todos.length,
//       itemBuilder: (context, index) {
//         final todo = todos[index];

//         return TweenAnimationBuilder<double>(
//           tween: Tween(begin: 0, end: 1),
//           duration: Duration(milliseconds: 300 + (index * 50)),
//           curve: Curves.easeOut,
//           builder: (context, value, child) {
//             return Opacity(
//               opacity: value,
//               child: Transform.translate(
//                 offset: Offset(0, 20 * (1 - value)),
//                 child: child,
//               ),
//             );
//           },
//           child: TodoItem(
//             todo: todo,
//             onToggle: () => _toggleTodoCompletion(todo.id),
//             onDelete: () => _deleteTodo(todo.id),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppConstants.defaultPadding,
//         vertical: AppConstants.smallPadding,
//       ),
//       child: Row(
//         children: [
//           FilterButton(
//             label: AppConstants.filterAll,
//             isActive: _currentFilter == FilterType.all,
//             onPressed: () {
//               setState(() => _currentFilter = FilterType.all);
//             },
//           ),
//           const SizedBox(width: AppConstants.smallPadding),
//           FilterButton(
//             label: AppConstants.filterActive,
//             isActive: _currentFilter == FilterType.active,
//             onPressed: () {
//               setState(() => _currentFilter = FilterType.active);
//             },
//           ),
//           const SizedBox(width: AppConstants.smallPadding),
//           FilterButton(
//             label: AppConstants.filterCompleted,
//             isActive: _currentFilter == FilterType.completed,
//             onPressed: () {
//               setState(() => _currentFilter = FilterType.completed);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection() {
//     return Padding(
//       padding: const EdgeInsets.all(AppConstants.defaultPadding),
//       child: Text(
//         AppConstants.getStatsText(_activeCount, _completedCount),
//         style: Theme.of(context).textTheme.bodySmall,
//       ),
//     );
//   }

//   /// Minimal bottom bar to add todos
//   Widget _buildAddTodoBar() {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return SafeArea(
//       top: false,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppConstants.defaultPadding,
//           vertical: AppConstants.smallPadding,
//         ),
//         color: isDarkMode ? Colors.black : Colors.white,
//         child: Row(
//           children: [
//             Expanded(
//               child: Material(
//                 elevation: 2, // subtle shadow for floating effect
//                 borderRadius: BorderRadius.circular(15),
//                 color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: TextField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       hintText: AppConstants.hintText,
//                       border: InputBorder.none, // remove default underline
//                     ),
//                     onSubmitted: (_) => _addTodo(),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Material(
//               color: isDarkMode ? Colors.white : Colors.black,
//               shape: const CircleBorder(),
//               child: IconButton(
//                 icon: Icon(
//                   Icons.add,
//                   color: isDarkMode ? Colors.black : Colors.white,
//                 ),
//                 onPressed: _addTodo,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
