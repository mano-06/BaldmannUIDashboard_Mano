import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/project.dart';
import 'package:baldmann_ui_dashboard/viewmodels/projects/projects_providers.dart';
import 'package:baldmann_ui_dashboard/viewmodels/employees/employee_providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewProjectModal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewPadding.bottom + 72),
        child: projects.when(
          data: (list) {
            if (list.isEmpty) return const Center(child: Text('No projects yet'));
            return Column(
              children: [
                _GanttView(projects: list),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) => _ProjectTile(p: list[index]),
                  ),
                ),

              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Future<void> _showNewProjectModal(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final lenCtrl = TextEditingController(text: '30');
    ProjectStatus status = ProjectStatus.planned;
    String? ownerId;
    final selectedTeam = <String>{};
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final employeesAsync = ref.watch(employeesProvider);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 8,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Project', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Project name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lenCtrl,
                    decoration: const InputDecoration(labelText: 'Length (days)'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ProjectStatus>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: ProjectStatus.planned, child: Text('Planned')),
                      DropdownMenuItem(value: ProjectStatus.inProgress, child: Text('In progress')),
                      DropdownMenuItem(value: ProjectStatus.blocked, child: Text('Blocked')),
                      DropdownMenuItem(value: ProjectStatus.done, child: Text('Done')),
                    ],
                    onChanged: (v) => status = v ?? status,
                  ),
                  const SizedBox(height: 12),
                  employeesAsync.when(
                    data: (emps) {
                      final items = [for (final e in emps) DropdownMenuItem(value: e.id, child: Text(e.name))];
                      ownerId ??= emps.isNotEmpty ? emps.first.id : null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: ownerId,
                            decoration: const InputDecoration(labelText: 'Owner'),
                            items: items,
                            onChanged: (v) => ownerId = v,
                            validator: (v) => v == null ? 'Select owner' : null,
                          ),
                          const SizedBox(height: 12),
                          _TeamDropdownField(
                            employees: emps,
                            selected: selectedTeam,
                            onChanged: () => (context as Element).markNeedsBuild(),
                          ),
                        ],
                      );
                    },
                    loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
                    error: (e, st) => Text('Error loading employees: $e'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final team = selectedTeam.isEmpty && ownerId != null ? [ownerId!] : selectedTeam.toList();
                      await ref.read(projectsProvider.notifier).addProject(
                            name: nameCtrl.text.trim(),
                            lengthDays: int.parse(lenCtrl.text.trim()),
                            status: status,
                            owner: ownerId ?? 'Owner 1',
                            team: team,
                          );
                      if (context.mounted) Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TeamDropdownField extends StatelessWidget {
  const _TeamDropdownField({required this.employees, required this.selected, required this.onChanged});
  final List<dynamic> employees; // Employee model
  final Set<String> selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final label = selected.isEmpty
        ? 'Select team members'
        : '${selected.length} member${selected.length == 1 ? '' : 's'} selected';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Team', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openMenu(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Team Members', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (c, i) {
                    final e = employees[i];
                    final isSel = selected.contains(e.id);
                    final bg = isSel ? Theme.of(ctx).colorScheme.primaryContainer : Colors.transparent;
                    final fg = isSel ? Theme.of(ctx).colorScheme.onPrimaryContainer : null;
                    return Material(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        title: Text(e.name, style: TextStyle(color: fg)),
                        trailing: Icon(isSel ? Icons.check_circle : Icons.circle_outlined, color: isSel ? Theme.of(ctx).colorScheme.primary : null),
                        onTap: () {
                          setState(() {
                            if (isSel) {
                              selected.remove(e.id);
                            } else {
                              selected.add(e.id);
                            }
                          });
                          onChanged();
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemCount: employees.length,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTile extends ConsumerStatefulWidget {
  const _ProjectTile({required this.p});
  final Project p;
  @override
  ConsumerState<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends ConsumerState<_ProjectTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final emps = ref.watch(employeesProvider).asData?.value ?? const [];
    final idToName = {for (final e in emps) e.id: e.name};
    final ownerName = idToName[p.owner] ?? p.owner;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      title: Text(p.name),
      subtitle: Text('$ownerName • ${p.start.toString().split(' ').first} → ${p.end.toString().split(' ').first}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedStatus(status: p.status, color: p.color, progress: p.progress, controller: _ac),
          const SizedBox(width: 8),
          PopupMenuButton<ProjectStatus>(
            tooltip: 'Change status',
            icon: const Icon(Icons.more_vert),
            onSelected: (st) => ref.read(projectsProvider.notifier).updateStatus(p.id, st),
            itemBuilder: (context) => const [
              PopupMenuItem(value: ProjectStatus.planned, child: Text('Planned')),
              PopupMenuItem(value: ProjectStatus.inProgress, child: Text('In progress')),
              PopupMenuItem(value: ProjectStatus.blocked, child: Text('Blocked')),
              PopupMenuItem(value: ProjectStatus.done, child: Text('Done')),
            ],
          ),
        ],
      ),
      onTap: () => _showDetails(context, p),
    );
  }

  void _showDetails(BuildContext context, Project p) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Builder(builder: (_) {
              final emps = ref.read(employeesProvider).asData?.value ?? const [];
              final idToName = {for (final e in emps) e.id: e.name};
              final ownerName = idToName[p.owner] ?? p.owner;
              return Text('Owner: $ownerName');
            }),
            Text('Duration: ${p.start.toString().split(' ').first} → ${p.end.toString().split(' ').first}'),
            const SizedBox(height: 8),
            Builder(builder: (_) {
              final emps = ref.read(employeesProvider).asData?.value ?? const [];
              final idToName = {for (final e in emps) e.id: e.name};
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in p.team) Chip(label: Text(idToName[id] ?? id)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatus extends StatelessWidget {
  const _AnimatedStatus({required this.status, required this.color, required this.progress, required this.controller});
  final ProjectStatus status;
  final Color color;
  final double progress;
  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      ProjectStatus.planned => 'Planned',
      ProjectStatus.inProgress => 'In progress',
      ProjectStatus.blocked => 'Blocked',
      ProjectStatus.done => 'Done',
    };
    final bg = switch (status) {
      ProjectStatus.planned => Colors.grey.shade200,
      ProjectStatus.inProgress => color.withOpacity(0.15),
      ProjectStatus.blocked => Colors.red.withOpacity(0.15),
      ProjectStatus.done => Colors.green.withOpacity(0.15),
    };
    final fg = switch (status) {
      ProjectStatus.planned => Colors.grey,
      ProjectStatus.inProgress => color,
      ProjectStatus.blocked => Colors.red,
      ProjectStatus.done => Colors.green,
    };
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ShapeDecoration(
            color: Color.lerp(Colors.white, bg, v),
            shape: StadiumBorder(side: BorderSide(color: fg.withOpacity(0.3))),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: status == ProjectStatus.done ? 1 : math.max(0.1, progress * v),
                  color: fg,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(color: fg)),
            ],
          ),
        );
      },
    );
  }
}

class _GanttView extends StatelessWidget {
  const _GanttView({required this.projects});
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) return const SizedBox.shrink();
    final minStart = projects.map((p) => p.start).reduce((a, b) => a.isBefore(b) ? a : b);
    final maxEnd = projects.map((p) => p.end).reduce((a, b) => a.isAfter(b) ? a : b);
    const barHeight = 18.0;
    const gap = 10.0;
    final contentHeight = 8.0 + projects.length * (barHeight + gap);
    const outerHeight = 220.0;
    return SizedBox(
      height: outerHeight,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: SizedBox(
                height: contentHeight,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GanttPainter(projects: projects, minStart: minStart, maxEnd: maxEnd),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GanttPainter extends CustomPainter {
  _GanttPainter({required this.projects, required this.minStart, required this.maxEnd});
  final List<Project> projects;
  final DateTime minStart;
  final DateTime maxEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final total = maxEnd.difference(minStart).inDays.toDouble().clamp(1.0, double.infinity);
    final barHeight = 18.0;
    final gap = 10.0;
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < projects.length; i++) {
      final p = projects[i];
      final y = i * (barHeight + gap) + 8.0;
      final startOff = p.start.difference(minStart).inDays.toDouble();
      final len = p.end.difference(p.start).inDays.toDouble();
      final x = (startOff / total) * size.width;
      final w = (len / total) * size.width;
      paint.color = p.color.withOpacity(0.8);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, math.max(6, w), barHeight), const Radius.circular(6));
      canvas.drawRRect(r, paint);
      // label (single line with ellipsis within bar width)
      final available = w - 8; // padding
      if (available > 8) {
        textPainter
          ..text = TextSpan(text: p.name, style: const TextStyle(fontSize: 10, color: Colors.white))
          ..maxLines = 1
          ..ellipsis = '…'
          ..layout(maxWidth: available);
        textPainter.paint(canvas, Offset(x + 4, y + (barHeight - textPainter.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GanttPainter oldDelegate) => oldDelegate.projects != projects;
}
