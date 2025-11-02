import 'dart:math';
import 'package:baldmann_ui_dashboard/data/models/task.dart';

class TaskService {
  const TaskService();

  Future<List<TaskItem>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rnd = Random(9);
    TaskPriority prio(int i) => TaskPriority.values[i % TaskPriority.values.length];
    List<Subtask> subs(int base) => List.generate(1 + (base % 3), (i) => Subtask(id: 's${base}_$i', title: 'Subtask ${i + 1}'));
    return List.generate(20, (i) {
      return TaskItem(
        id: 'task_$i',
        title: 'Task ${i + 1}',
        description: 'This is a description for task ${i + 1}.',
        priority: prio(i),
        completed: false,
        due: DateTime.now().add(Duration(days: rnd.nextInt(14))),
        subtasks: subs(i),
      );
    });
  }
}
