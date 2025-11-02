import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/notifications/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showToast(context),
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('Show toast'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final n = items[i];
          final color = n.type == NotificationType.taskDue ? Colors.orange : Colors.redAccent;
          return ListTile(
            leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(n.type == NotificationType.taskDue ? Icons.event : Icons.warning_amber_outlined, color: color)),
            title: Text(n.title),
            subtitle: Text(n.message),
            trailing: Text(n.time.toString().split(' ').first),
          );
        },
      ),
    );
  }
}

void _showToast(BuildContext context) {
  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    content: Row(
      children: const [
        Icon(Icons.notifications, color: Colors.white),
        SizedBox(width: 8),
        Text('You have new alerts!'),
      ],
    ),
  );
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(snack);
}
