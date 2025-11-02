import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/task.dart';
import 'package:baldmann_ui_dashboard/viewmodels/tasks/tasks_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: tasks.when(
          data: (list) {
            if (list.isEmpty) return const Center(child: Text('No tasks'));
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _TaskTile(task: list[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _TaskTile extends StatefulWidget {
  const _TaskTile({required this.task});
  final TaskItem task;

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.low => Colors.green,
        TaskPriority.medium => Colors.orange,
        TaskPriority.high => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final color = _priorityColor(t.priority);
    return RepaintBoundary(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            _AnimatedCheckbox(checked: t.completed, controller: _ac),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      decoration: t.completed ? TextDecoration.lineThrough : null,
                      color: t.completed ? Colors.grey : null,
                    ),
                child: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            _PriorityBadge(priority: t.priority, color: color),
          ],
        ),
        subtitle: Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: t.due != null ? Text('Due ${t.due!.toString().split(' ').first}') : null,
        onExpansionChanged: (open) {
          if (open) _ac.forward();
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: _SubtasksList(task: t, controller: _ac),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority, required this.color});
  final TaskPriority priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = switch (priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: ShapeDecoration(
        color: color.withOpacity(0.12),
        shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.4))),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

class _AnimatedCheckbox extends ConsumerWidget {
  const _AnimatedCheckbox({required this.checked, required this.controller});
  final bool checked;
  final AnimationController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (checked) {
          controller.reverse();
        } else {
          controller.forward();
        }
        ref.read(tasksProvider.notifier).toggleComplete(
              (context.findAncestorWidgetOfExactType<_TaskTile>()!).task.id,
              !checked,
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: checked ? Theme.of(context).colorScheme.primary : Colors.transparent,
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: checked ? 1 : 0,
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _SubtasksList extends ConsumerWidget {
  const _SubtasksList({required this.task, required this.controller});
  final TaskItem task;
  final AnimationController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final s in task.subtasks)
          ListTile(
            dense: true,
            leading: GestureDetector(
              onTap: () => ref.read(tasksProvider.notifier).toggleSubtask(task.id, s.id, !s.completed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.completed ? Colors.green : Colors.transparent,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: s.completed ? 1 : 0,
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: s.completed ? TextDecoration.lineThrough : null,
                    color: s.completed ? Colors.grey : null,
                  ),
              child: Text(s.title),
            ),
          ),
      ],
    );
  }
}
