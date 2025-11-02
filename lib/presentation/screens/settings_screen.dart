import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/theme/theme_provider.dart';
import 'package:baldmann_ui_dashboard/viewmodels/settings/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final scale = ref.watch(textScaleProvider);
    final primary = ref.watch(primaryColorProvider);
    final notif = ref.watch(notificationsEnabledProvider);
    final profile = ref.watch(profileProvider);
    final lang = ref.watch(languageProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.auto_mode)),
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setTheme(s.first),
            ),
            const SizedBox(height: 16),
            Text('Font scale', style: Theme.of(context).textTheme.titleLarge),
            Slider(
              value: scale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: scale.toStringAsFixed(1),
              onChanged: (v) => ref.read(textScaleProvider.notifier).state = v,
            ),
            Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            SwitchListTile(
              value: notif,
              onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v,
              title: const Text('Enable notifications'),
              subtitle: const Text('Show in-app alerts and reminders'),
            ),
            const Divider(height: 32),
            Text('Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              controller: TextEditingController(text: profile.name),
              onSubmitted: (v) => ref.read(profileProvider.notifier).state = profile.copyWith(name: v),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              controller: TextEditingController(text: profile.email),
              onSubmitted: (v) => ref.read(profileProvider.notifier).state = profile.copyWith(email: v),
            ),
            const SizedBox(height: 16),
            Text('Language', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: lang,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                DropdownMenuItem(value: 'ta', child: Text('Tamil')),
              ],
              onChanged: (v) => ref.read(languageProvider.notifier).state = v ?? 'en',
            ),
          ],
        ),
      ),
    );
  }
}
