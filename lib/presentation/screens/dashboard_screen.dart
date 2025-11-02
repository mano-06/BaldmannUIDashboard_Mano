import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/dashboard/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dashboardStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _KpiCard(title: 'Projects', value: s.projects.toString(), icon: Icons.work_outline),
                _KpiCard(title: 'Active Tasks', value: s.activeTasks.toString(), icon: Icons.checklist_outlined),
                _KpiCard(title: 'Employees', value: s.employees.toString(), icon: Icons.people_alt_outlined),
                _OnTrackCard(value: s.onTrack),
              ],
            ),
            const SizedBox(height: 16),
            Text('Throughput (last 12 ticks)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ThroughputBars(points: s.throughput),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  Text(value, style: theme.textTheme.headlineSmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _OnTrackCard extends StatefulWidget {
  const _OnTrackCard({required this.value});
  final double value;

  @override
  State<_OnTrackCard> createState() => _OnTrackCardState();
}

class _OnTrackCardState extends State<_OnTrackCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  double _prev = 0;

  @override
  void didUpdateWidget(covariant _OnTrackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prev = oldWidget.value;
    _ac.forward(from: 0);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, _) {
                    final t = Tween<double>(begin: _prev, end: widget.value).transform(_ac.value).clamp(0.0, 1.0);
                    return CustomPaint(painter: _RingPainter(progress: t), child: Center(child: Text('${(t * 100).round()}%')));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('On track', style: theme.textTheme.labelLarge),
                  Text('Projects', style: theme.textTheme.titleMedium),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.grey.withOpacity(0.2);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = Colors.green;
    canvas.drawCircle(center, radius, bg);
    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ThroughputBars extends StatelessWidget {
  const _ThroughputBars({required this.points});
  final List<double> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: (p.clamp(0.0, 1.0)) * 76 + 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3 + 0.4 * p),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
