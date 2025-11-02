import 'package:baldmann_ui_dashboard/data/models/employee.dart';

class EmployeeService {
  const EmployeeService();

  Future<List<Employee>> fetchEmployees() async {
    await Future.delayed(const Duration(milliseconds: 300));
    const base = 'https://i.pravatar.cc/150?img=';
    return List.generate(30, (i) {
      final perf = 60 + (i * 7) % 45;
      final rating = 3 + ((i % 20) / 20) * 2;
      final departments = ['Engineering', 'Design', 'Sales', 'HR'];
      final roles = ['Developer', 'Designer', 'Manager', 'Analyst'];
      return Employee(
        id: 'emp_$i',
        name: 'Employee ${i + 1}',
        role: roles[i % roles.length],
        department: departments[i % departments.length],
        performance: perf.toDouble(),
        rating: double.parse(rating.toStringAsFixed(1)),
        imageUrl: '$base${(i % 70) + 1}',
      );
    });
  }
}
