import 'dart:math';
import 'package:flutter/material.dart';
import 'package:baldmann_ui_dashboard/data/models/project.dart';

class ProjectService {
  const ProjectService();

  Future<List<Project>> fetchProjects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final rnd = Random(7);
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal,
    ];
    Project mk(String name, int offsetDays, int len, ProjectStatus st) {
      final start = now.subtract(Duration(days: offsetDays));
      final end = start.add(Duration(days: len));
      final progress = st == ProjectStatus.done
          ? 1.0
          : st == ProjectStatus.blocked
              ? 0.35
              : (0.2 + rnd.nextDouble() * 0.6);
      return Project(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        status: st,
        start: start,
        end: end,
        progress: progress,
        owner: 'Owner ${rnd.nextInt(9) + 1}',
        team: List.generate(3 + rnd.nextInt(3), (i) => 'emp_${rnd.nextInt(30)}'),
        color: colors[rnd.nextInt(colors.length)],
      );
    }

    return [
      mk('Mobile App', 30, 60, ProjectStatus.inProgress),
      mk('Website Revamp', 10, 25, ProjectStatus.blocked),
      mk('Marketing Sprint', 5, 15, ProjectStatus.inProgress),
      mk('Data Migration', 60, 90, ProjectStatus.planned),
      mk('Ops Automation', 120, 150, ProjectStatus.done),
    ];
  }
}
