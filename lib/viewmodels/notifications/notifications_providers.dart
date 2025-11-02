import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/tasks/tasks_providers.dart';
import 'package:baldmann_ui_dashboard/viewmodels/projects/projects_providers.dart';

import '../../data/models/project.dart';

enum NotificationType { taskDue, projectAlert }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  const AppNotification({required this.id, required this.type, required this.title, required this.message, required this.time});
}

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final tasks = ref.watch(tasksProvider).maybeWhen(data: (v) => v, orElse: () => const []);
  final projects = ref.watch(projectsProvider).maybeWhen(data: (v) => v, orElse: () => const []);
  final now = DateTime.now();
  final dueSoon = tasks.where((t) => t.due != null && t.due!.isAfter(now) && t.due!.difference(now).inDays <= 3 && !t.completed);
  final blocked = projects.where((p) => p.status == ProjectStatus.blocked);
  final soonStart = projects.where((p) => p.start.isAfter(now) && p.start.difference(now).inDays <= 7);

  final items = <AppNotification>[
    for (final t in dueSoon)
      AppNotification(
        id: 'task_${t.id}',
        type: NotificationType.taskDue,
        title: 'Task due soon',
        message: '${t.title} due on ${t.due!.toString().split(' ').first}',
        time: t.due!,
      ),
    for (final p in blocked)
      AppNotification(
        id: 'proj_block_${p.id}',
        type: NotificationType.projectAlert,
        title: 'Project blocked',
        message: '${p.name} needs attention',
        time: now.subtract(const Duration(hours: 2)),
      ),
    for (final p in soonStart)
      AppNotification(
        id: 'proj_soon_${p.id}',
        type: NotificationType.projectAlert,
        title: 'Project starting soon',
        message: '${p.name} starts ${p.start.toString().split(' ').first}',
        time: p.start,
      ),
  ];

  items.sort((a, b) => a.time.compareTo(b.time));
  return items;
});
