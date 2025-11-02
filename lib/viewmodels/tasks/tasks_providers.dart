import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/task.dart';
import 'package:baldmann_ui_dashboard/data/services/task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) => const TaskService());

class TasksController extends AsyncNotifier<List<TaskItem>> {
  @override
  Future<List<TaskItem>> build() async {
    final svc = ref.read(taskServiceProvider);
    return svc.fetchTasks();
  }

  void toggleComplete(String id, bool value) {
    final current = state.asData?.value ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == id)
          t.copyWith(completed: value, subtasks: [
            for (final s in t.subtasks) s.copyWith(completed: value ? true : s.completed),
          ])
        else
          t,
    ]);
  }

  void toggleSubtask(String taskId, String subId, bool value) {
    final current = state.asData?.value ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == taskId)
          t.copyWith(
            subtasks: [
              for (final s in t.subtasks)
                if (s.id == subId) s.copyWith(completed: value) else s,
            ],
            completed: value ? t.subtasks.every((s) => s.completed || s.id == subId) : false,
          )
        else
          t,
    ]);
  }
}

final tasksProvider = AsyncNotifierProvider<TasksController, List<TaskItem>>(TasksController.new);
