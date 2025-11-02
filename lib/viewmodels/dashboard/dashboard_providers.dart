import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/project.dart';
import 'package:baldmann_ui_dashboard/viewmodels/projects/projects_providers.dart';
import 'package:baldmann_ui_dashboard/viewmodels/tasks/tasks_providers.dart';
import 'package:baldmann_ui_dashboard/viewmodels/employees/employee_providers.dart';
import 'package:baldmann_ui_dashboard/viewmodels/reports/reports_providers.dart';

class DashboardStats {
  final int projects;
  final int activeTasks;
  final int employees;
  final double onTrack; // 0..1
  final List<double> throughput; // 12 points 0..1
  const DashboardStats({
    required this.projects,
    required this.activeTasks,
    required this.employees,
    required this.onTrack,
    required this.throughput,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  // Projects
  final projects = ref.watch(projectsProvider).maybeWhen(data: (v) => v, orElse: () => const <Project>[]);
  // Tasks
  final tasks = ref.watch(tasksProvider).maybeWhen(data: (v) => v, orElse: () => const []);
  // Employees
  final employees = ref.watch(employeesProvider).maybeWhen(data: (v) => v, orElse: () => const []);
  // Reports throughput (normalize to 12 points by sampling/padding)
  final report = ref.watch(reportsDataProvider);
  final pts = report.line.map((e) => e.y.clamp(0.0, 1.0)).toList();
  List<double> throughput;
  if (pts.length >= 12) {
    final step = (pts.length / 12).floor();
    throughput = [for (int i = 0; i < 12; i++) pts[i * step]];
  } else {
    throughput = [...pts, ...List.filled(12 - pts.length, pts.isEmpty ? 0.0 : pts.last)].sublist(0, 12);
  }

  // OnTrack: ratio of projects not blocked (planned, inProgress, done)
  final onTrackCount = projects.where((p) => p.status != ProjectStatus.blocked).length;
  final onTrack = projects.isEmpty ? 0.0 : onTrackCount / projects.length;

  final activeTasks = tasks.where((t) => !t.completed).length;

  return DashboardStats(
    projects: projects.length,
    activeTasks: activeTasks,
    employees: employees.length,
    onTrack: onTrack.clamp(0.0, 1.0),
    throughput: throughput,
  );
});
