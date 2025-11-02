import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baldmann_ui_dashboard/viewmodels/auth/auth_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;
  void _goBranch(BuildContext context, int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = <({IconData icon, String label, String route})>[
      (icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard'),
      (icon: Icons.people_alt_outlined, label: 'Employees', route: '/employees'),
      (icon: Icons.work_outline, label: 'Projects', route: '/projects'),
      (icon: Icons.checklist_outlined, label: 'Tasks', route: '/tasks'),
      (icon: Icons.insights_outlined, label: 'Reports', route: '/reports'),
      (icon: Icons.notifications_outlined, label: 'Alerts', route: '/notifications'),
      (icon: Icons.emoji_events_outlined, label: 'Awards', route: '/achievements'),
      (icon: Icons.settings_outlined, label: 'Settings', route: '/settings'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: const Text('BaldMannUI Dashboard'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Navigation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final d = destinations[index];
                    final selected = index == navigationShell.currentIndex;
                    return ListTile(
                      leading: Icon(d.icon),
                      title: Text(d.label),
                      selected: selected,
                      onTap: () {
                        Navigator.of(context).pop();
                        _goBranch(context, index);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: navigationShell,
    );
  }
}
