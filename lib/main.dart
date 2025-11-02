import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baldmann_ui_dashboard/core/constants/app_constants.dart';
import 'package:baldmann_ui_dashboard/core/router/app_router.dart';
import 'package:baldmann_ui_dashboard/core/theme/app_theme.dart';
import 'package:baldmann_ui_dashboard/viewmodels/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
