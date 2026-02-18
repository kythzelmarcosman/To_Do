/// Represents a single todo item.
///
/// This class is immutable to ensure consistency and predictability
/// when managing todo state.
class Todo {
  /// Unique identifier for the todo.
  final String id;

  /// Title or description of the todo.
  final String title;

  /// Whether the todo has been completed.
  final bool isCompleted;

  /// Timestamp when the todo was created.
  final DateTime createdAt;

  /// Creates a new [Todo] instance.
  ///
  /// The [id] and [title] are required. [createdAt] defaults to the current
  /// time if not provided.
  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this todo with the specified fields replaced.
  ///
  /// Used to create modified versions of a todo while maintaining immutability.
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ isCompleted.hashCode ^ createdAt.hashCode;
}
