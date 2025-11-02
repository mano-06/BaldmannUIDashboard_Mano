# Baldmann UI Dashboard

## 1. Project Overview

Baldmann is a Flutter (Material 3) dashboard showcasing production-grade UI, animations, Riverpod state management, clean architecture, and performance optimizations. It includes modules: Authentication, Dashboard, Employees, Projects (with Gantt), Tasks, Reports (fl_chart), Notifications, Achievements, and Settings.

Key highlights:
- Riverpod for app-wide and scoped state.
- Smooth animations (implicit/explicit), custom painters, and snackbars.
- Performance focus with `RepaintBoundary`, cached images, efficient lists.
- Responsive layouts for phones/tablets.

## 2. Architecture Explanation

Clean structure:
- `core/`: routing, constants, theme.
- `data/`: models and services (dummy data providers).
- `viewmodels/`: Riverpod providers and controllers.
- `presentation/`: screens and widgets per module.

Patterns:
- Model–Service–Provider: data models, dummy services, Riverpod providers and AsyncNotifiers.
- Navigation uses `go_router` with custom fade+slide transitions and auth-guard redirects.

## 3. Setup Instructions

Prerequisites: Flutter stable (3.22+), Dart SDK.

Steps:
1. `flutter pub get`
2. Run: `flutter run -d windows` or simulator/device of choice.
3. Login with demo credentials:
   - Email: `admin@baldmann.com`
   - Password: `Admin@123`

## 4. Folder Structure

```
lib/
  core/
    router/app_router.dart
    theme/app_theme.dart
    constants/app_constants.dart
  data/
    models/ (employee.dart, project.dart, task.dart)
    services/ (employee_service.dart, project_service.dart, task_service.dart)
  viewmodels/
    auth/, theme/
    employees/, projects/, tasks/
    reports/, dashboard/, notifications/, achievements/, settings/
  presentation/
    screens/ (..._screen.dart)
```

## 5. Performance Profiling Report

Optimizations implemented:
- `const` widgets where possible.
- `ListView.separated`/`builder` for dynamic lists.
- `RepaintBoundary` wrapping heavy charts (Reports) and animated sheets.
- Cached images via `CachedNetworkImageProvider` for employee avatars.
- Custom paints optimized (Gantt bars, progress rings) using minimal allocations.

Observed in Flutter DevTools (debug, Windows desktop):
- FPS steady near vsync for list interactions and navigation.
- Gantt and charts remain under frame budget; no significant jank observed.
- Memory stable; no provider leaks detected.

How to profile:
1. Run app in profile mode: `flutter run --profile`.
2. Open DevTools (Performance tab).
3. Record while navigating Dashboard → Projects (Gantt) → Reports (charts) → Employees (avatars) → Achievements.
4. Inspect frame timings, raster/gpu charts and rebuild counts.

## Features Summary

- Dashboard: KPI cards, animated progress ring, throughput bars derived from app data.
- Employees: list with search/filter, animated performance badges, profile bottom sheet, cached avatars.
- Projects: list with animated status badges, Gantt timeline (scrollable, ellipsis labels), add-project modal.
- Tasks: list with priority badges, animated checkbox, subtasks with animated checkmarks.
- Reports: fl_chart line & pie charts, filter chips, drill-down bottom sheets, perf wrappers.
- Notifications: task due soon and project alerts, animated snackbar.
- Achievements: top performers (derived), animated badges, celebration snackbar.
- Settings: theme switch, font scale, notifications toggle, profile edit, language selection.

## Testing

Widget tests are under `test/`:
- `dashboard_and_reports_test.dart`
  - Dashboard renders KPIs and percent.
  - Reports builds line/pie charts; tap interaction sanity check.

Run tests:
```
flutter test
```

## Accessibility & Responsiveness

- Material 3 components.
- Text scaling supported via Settings (font scale).
- Layouts adapt to larger screens (Cards/Wraps, paddings).

## Notes

This project uses dummy services and derived providers for demonstration. Replace services with real repositories or API clients as needed.
