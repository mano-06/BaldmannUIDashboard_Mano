import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


enum ReportRange { d7, d30, d90 }

class ReportPoint {
  final DateTime x;
  final double y; // normalized 0..1
  const ReportPoint(this.x, this.y);
}

class ReportData {
  final List<ReportPoint> line;
  final Map<String, double> categories;
  const ReportData({required this.line, required this.categories});
}

final reportRangeProvider = StateProvider<ReportRange>((ref) => ReportRange.d30);

final reportsDataProvider = Provider<ReportData>((ref) {
  final range = ref.watch(reportRangeProvider);
  final now = DateTime.now();
  final rnd = Random(5 + range.index);
  final len = switch (range) { ReportRange.d7 => 7, ReportRange.d30 => 30, ReportRange.d90 => 30 /* sample fewer points for perf */ };
  final stepDays = switch (range) { ReportRange.d7 => 1, ReportRange.d30 => 1, ReportRange.d90 => 3 };
  final line = List.generate(len, (i) {
    final day = now.subtract(Duration(days: (len - 1 - i) * stepDays));
    final v = (0.3 + rnd.nextDouble() * 0.6) * (1 + 0.05 * (i % 5 - 2));
    return ReportPoint(day, v.clamp(0.0, 1.0));
  });
  // categories
  final cats = {
    'Engineering': 0.30 + rnd.nextDouble() * 0.1,
    'Design': 0.20 + rnd.nextDouble() * 0.1,
    'Sales': 0.25 + rnd.nextDouble() * 0.1,
    'Ops': 0.15 + rnd.nextDouble() * 0.1,
  };
  final sum = cats.values.fold<double>(0, (a, b) => a + b);
  final norm = {for (final e in cats.entries) e.key: e.value / sum};
  return ReportData(line: line, categories: norm);
});
