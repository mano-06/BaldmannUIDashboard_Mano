import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/data/models/employee.dart';
import 'package:baldmann_ui_dashboard/data/services/employee_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) => const EmployeeService());

class EmployeesController extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() async {
    final svc = ref.read(employeeServiceProvider);
    return svc.fetchEmployees();
  }

  Future<void> addEmployee({
    required String name,
    required String role,
    required String department,
    String? imageUrl,
  }) async {
    final current = state.asData?.value ?? [];
    final idx = current.length + 1;
    final emp = Employee(
      id: 'emp_${idx}',
      name: name,
      role: role,
      department: department,
      performance: 75.0,
      rating: 4.2,
      imageUrl: imageUrl ?? 'https://i.pravatar.cc/150?img=${(idx % 70) + 1}',
    );
    state = AsyncData(<Employee>[emp, ...current]);
  }
}

final employeesProvider = AsyncNotifierProvider<EmployeesController, List<Employee>>(EmployeesController.new);

final employeeSearchQueryProvider = StateProvider<String>((ref) => '');
final employeeDepartmentFilterProvider = StateProvider<String?>((ref) => null);

final filteredEmployeesProvider = Provider<AsyncValue<List<Employee>>>((ref) {
  final all = ref.watch(employeesProvider);
  final q = ref.watch(employeeSearchQueryProvider).trim().toLowerCase();
  final dept = ref.watch(employeeDepartmentFilterProvider);
  return all.whenData((list) {
    return list.where((e) {
      final matchesQuery = q.isEmpty || e.name.toLowerCase().contains(q) || e.role.toLowerCase().contains(q);
      final matchesDept = dept == null || e.department == dept;
      return matchesQuery && matchesDept;
    }).toList();
  });
});
