import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/employee.dart';
import 'package:baldmann_ui_dashboard/viewmodels/employees/employee_providers.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredEmployeesProvider);
    final q = ref.watch(employeeSearchQueryProvider);
    final dept = ref.watch(employeeDepartmentFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployee(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name or role...',
                    ),
                    onChanged: (v) => ref.read(employeeSearchQueryProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: dept,
                  hint: const Text('Department'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                    DropdownMenuItem(value: 'Design', child: Text('Design')),
                    DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                    DropdownMenuItem(value: 'HR', child: Text('HR')),
                  ],
                  onChanged: (v) => ref.read(employeeDepartmentFilterProvider.notifier).state = v,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No employees found'));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final e = list[index];
                      return _EmployeeTile(emp: e, index: index);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddEmployee(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final role = TextEditingController();
  String? dept;
  final image = TextEditingController();
  final key = GlobalKey<FormState>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Employee', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: role,
              decoration: const InputDecoration(labelText: 'Role'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a role' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: dept,
              decoration: const InputDecoration(labelText: 'Department'),
              items: const [
                DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                DropdownMenuItem(value: 'Design', child: Text('Design')),
                DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                DropdownMenuItem(value: 'HR', child: Text('HR')),
              ],
              onChanged: (v) => dept = v,
              validator: (v) => v == null ? 'Choose a department' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: image,
              decoration: const InputDecoration(labelText: 'Image URL (optional)'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                if (!key.currentState!.validate()) return;
                await ref.read(employeesProvider.notifier).addEmployee(
                      name: name.text.trim(),
                      role: role.text.trim(),
                      department: dept!,
                      imageUrl: image.text.trim().isEmpty ? null : image.text.trim(),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.save),
              label: const Text('Add Employee'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmployeeTile extends StatefulWidget {
  const _EmployeeTile({required this.emp, required this.index});
  final Employee emp;
  final int index;

  @override
  State<_EmployeeTile> createState() => _EmployeeTileState();
}

class _EmployeeTileState extends State<_EmployeeTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _tween = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);

  @override
  void initState() {
    super.initState();
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.emp;
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(e.imageUrl),
      ),
      title: Text(e.name),
      subtitle: Text('${e.role} • ${e.department}'),
      trailing: _AnimatedPerfBadge(value: e.performance / 100, color: e.isTopPerformer ? Colors.green : Colors.orange, controller: _tween),
      onTap: () => _showProfile(context, e),
    );
  }

  Future<void> _showProfile(BuildContext context, Employee e) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider(e.imageUrl)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.name, style: Theme.of(context).textTheme.titleLarge)),
                    _AnimatedPerfBadge(value: e.performance / 100, color: e.isTopPerformer ? Colors.green : Colors.orange, controller: const AlwaysStoppedAnimation(1)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Role: ${e.role}'),
                Text('Department: ${e.department}'),
                Text('Performance: ${e.performance.toStringAsFixed(0)}%'),
                Text('Rating: ${e.rating.toStringAsFixed(1)} / 5.0'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedPerfBadge extends StatelessWidget {
  const _AnimatedPerfBadge({required this.value, required this.color, required this.controller});
  final double value; // 0..1
  final Color color;
  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final v = (value * controller.value).clamp(0.0, 1.0);
          return CustomPaint(
            painter: _RingPainter(progress: v, color: color),
            child: Center(
              child: Text('${(v * 100).round()}%', style: Theme.of(context).textTheme.labelSmall),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 4.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.grey.withOpacity(0.2);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    // background circle
    canvas.drawCircle(center, radius, bg);
    // arc
    final start = -90.0 * 3.14159265 / 180.0;
    final sweep = 2 * 3.14159265 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
