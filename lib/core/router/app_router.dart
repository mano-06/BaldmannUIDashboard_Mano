import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:baldmann_ui_dashboard/presentation/screens/home_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/employees_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/projects_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/tasks_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/reports_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/notifications_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/achievements_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/settings_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/auth_login_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/auth_register_screen.dart';
import 'package:baldmann_ui_dashboard/presentation/screens/auth_forgot_password_screen.dart';
import 'package:baldmann_ui_dashboard/viewmodels/auth/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final key = GlobalKey<NavigatorState>(debugLabel: 'routerKey');
  final auth = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: key,
    initialLocation: '/login',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _fadeSlide(const AuthLoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _fadeSlide(const AuthRegisterScreen()),
      ),
      GoRoute(
        path: '/forgot',
        name: 'forgot',
        pageBuilder: (context, state) => _fadeSlide(const AuthForgotPasswordScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              pageBuilder: (context, state) => _fadeSlide(const DashboardScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/employees',
              name: 'employees',
              pageBuilder: (context, state) => _fadeSlide(const EmployeesScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/projects',
              name: 'projects',
              pageBuilder: (context, state) => _fadeSlide(const ProjectsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              pageBuilder: (context, state) => _fadeSlide(const TasksScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reports',
              name: 'reports',
              pageBuilder: (context, state) => _fadeSlide(const ReportsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              pageBuilder: (context, state) => _fadeSlide(const NotificationsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/achievements',
              name: 'achievements',
              pageBuilder: (context, state) => _fadeSlide(const AchievementsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) => _fadeSlide(const SettingsScreen()),
            ),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuth = auth == AuthStatus.authenticated;
      final loggingIn = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/forgot';
      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) return '/dashboard';
      return null;
    },
  );
});

CustomTransitionPage _fadeSlide(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(begin: const Offset(0.02, 0.02), end: Offset.zero).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
