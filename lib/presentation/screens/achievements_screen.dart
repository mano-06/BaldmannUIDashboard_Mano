import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/achievements/achievements_providers.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performers = ref.watch(topPerformersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _celebrate(context),
        icon: const Icon(Icons.emoji_events_outlined),
        label: const Text('Celebrate'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: performers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final p = performers[i];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl)),
            title: Row(
              children: [
                Expanded(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                _AnimatedBadge(percent: p.performance / 100.0, controller: _ac),
              ],
            ),
            subtitle: Text(p.department),
            trailing: Text('${p.performance}%'),
          );
        },
      ),
    );
  }

  void _celebrate(BuildContext context) {
    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: const [
          Icon(Icons.celebration, color: Colors.white),
          SizedBox(width: 8),
          Text('Congrats to top performers!'),
        ],
      ),
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snack);
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.percent, required this.controller});
  final double percent;
  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 0.8
        ? Colors.green
        : percent >= 0.6
            ? Colors.orange
            : Colors.red;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: ShapeDecoration(
            color: color.withOpacity(0.15 + 0.2 * v),
            shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.5))),
          ),
          child: Text('Top', style: TextStyle(color: color)),
        );
      },
    );
  }
}
