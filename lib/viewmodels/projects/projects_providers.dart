import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/project.dart';
import 'package:baldmann_ui_dashboard/data/services/project_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) => const ProjectService());

class ProjectsController extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final svc = ref.read(projectServiceProvider);
    return svc.fetchProjects();
  }

  Future<void> addProject({
    required String name,
    required int lengthDays,
    required ProjectStatus status,
    required String owner,
    required List<String> team,
  }) async {
    final now = DateTime.now();
    final newProject = Project(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      status: status,
      start: now,
      end: now.add(Duration(days: lengthDays)),
      progress: status == ProjectStatus.done ? 1.0 : 0.1,
      owner: owner,
      team: team,
      color: Colors.blue,
    );
    final current = state.asData?.value ?? [];
    state = AsyncData(<Project>[newProject, ...current]);
  }

  void updateStatus(String id, ProjectStatus status) {
    final current = state.asData?.value ?? [];
    final updated = [
      for (final p in current)
        if (p.id == id)
          Project(
            id: p.id,
            name: p.name,
            status: status,
            start: p.start,
            end: p.end,
            progress: status == ProjectStatus.done ? 1.0 : p.progress,
            owner: p.owner,
            team: p.team,
            color: p.color,
          )
        else
          p,
    ];
    state = AsyncData(updated);
  }
}

final projectsProvider = AsyncNotifierProvider<ProjectsController, List<Project>>(ProjectsController.new);
