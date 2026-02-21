import 'package:hive/hive.dart';
import 'todo.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  List<Todo> todos;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.todos,
  });
}
