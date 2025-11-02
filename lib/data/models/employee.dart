class Employee {
  final String id;
  final String name;
  final String role;
  final String department;
  final double performance; // 0..100
  final double rating; // 0..5
  final String imageUrl;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.performance,
    required this.rating,
    required this.imageUrl,
  });

  bool get isTopPerformer => performance >= 85;
}
