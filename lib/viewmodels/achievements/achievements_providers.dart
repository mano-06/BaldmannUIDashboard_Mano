import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/employees/employee_providers.dart';

class Performer {
  final String id;
  final String name;
  final String department;
  final double performance; // 0..100
  final String avatarUrl;
  const Performer({required this.id, required this.name, required this.department, required this.performance, required this.avatarUrl});
}

final topPerformersProvider = Provider<List<Performer>>((ref) {
  final employees = ref.watch(filteredEmployeesProvider).maybeWhen(data: (v) => v, orElse: () => const []);
  final sorted = [...employees]..sort((a, b) => b.performance.compareTo(a.performance));
  return [
    for (final e in sorted.take(10))
      Performer(id: e.id, name: e.name, department: e.department, performance: e.performance, avatarUrl: e.imageUrl),
  ];
});
