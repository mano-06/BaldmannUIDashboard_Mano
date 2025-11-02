enum TaskPriority { low, medium, high }

class Subtask {
  final String id;
  final String title;
  final bool completed;
  const Subtask({required this.id, required this.title, this.completed = false});

  Subtask copyWith({String? id, String? title, bool? completed}) =>
      Subtask(id: id ?? this.id, title: title ?? this.title, completed: completed ?? this.completed);
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final bool completed;
  final DateTime? due;
  final List<Subtask> subtasks;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.completed = false,
    this.due,
    this.subtasks = const [],
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    bool? completed,
    DateTime? due,
    List<Subtask>? subtasks,
  }) => TaskItem(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        completed: completed ?? this.completed,
        due: due ?? this.due,
        subtasks: subtasks ?? this.subtasks,
      );
}
