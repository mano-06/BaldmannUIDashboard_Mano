import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:baldmann_ui_dashboard/viewmodels/reports/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(reportsDataProvider);
    final range = ref.watch(reportRangeProvider);
    // simple derived metrics
    final totalPts = data.line.length;
    final avg = totalPts == 0 ? 0.0 : data.line.map((e) => e.y).reduce((a, b) => a + b) / totalPts;
    final maxVal = totalPts == 0 ? 0.0 : data.line.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Range filters
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('7D'),
                  selected: range == ReportRange.d7,
                  onSelected: (_) => ref.read(reportRangeProvider.notifier).state = ReportRange.d7,
                ),
                FilterChip(
                  label: const Text('30D'),
                  selected: range == ReportRange.d30,
                  onSelected: (_) => ref.read(reportRangeProvider.notifier).state = ReportRange.d30,
                ),
                FilterChip(
                  label: const Text('90D'),
                  selected: range == ReportRange.d90,
                  onSelected: (_) => ref.read(reportRangeProvider.notifier).state = ReportRange.d90,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick metrics row
            Row(
              children: [
                _MetricCard(title: 'Avg', value: '${(avg * 100).toStringAsFixed(0)}%'),
                const SizedBox(width: 8),
                _MetricCard(title: 'Max', value: '${(maxVal * 100).toStringAsFixed(0)}%'),
                const SizedBox(width: 8),
                _MetricCard(title: 'Points', value: '$totalPts'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Throughput over time', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Expanded(
                              child: RepaintBoundary(
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, meta) {
                                        final i = v.toInt();
                                        if (i < 0 || i >= data.line.length) return const SizedBox.shrink();
                                        final dt = data.line[i].x;
                                        return Text('${dt.month}/${dt.day}', style: const TextStyle(fontSize: 10));
                                      })),
                                    ),
                                    lineTouchData: LineTouchData(
                                      handleBuiltInTouches: true,
                                      touchCallback: (FlTouchEvent ev, LineTouchResponse? resp) {
                                        if (ev is FlTapUpEvent && resp?.lineBarSpots != null && resp!.lineBarSpots!.isNotEmpty) {
                                          final first = resp.lineBarSpots!.first;
                                          final i = first.x.toInt();
                                          if (i >= 0 && i < data.line.length) {
                                            final pt = data.line[i];
                                            _showPoint(context, pt);
                                          }
                                        }
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: (data.line.length - 1).toDouble(),
                                    minY: 0,
                                    maxY: 1,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          for (int i = 0; i < data.line.length; i++) FlSpot(i.toDouble(), data.line[i].y),
                                        ],
                                        isCurved: true,
                                        color: Theme.of(context).colorScheme.primary,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Tap a point to view details', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category distribution', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Expanded(
                              child: RepaintBoundary(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 28,
                                    sections: [
                                      for (final e in data.categories.entries)
                                        PieChartSectionData(
                                          title: '${(e.value * 100).round()}%',
                                          value: e.value,
                                          radius: 50 + (e.value * 20),
                                          color: Colors.primaries[data.categories.keys.toList().indexOf(e.key) % Colors.primaries.length],
                                          titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                                        ),
                                    ],
                                    pieTouchData: PieTouchData(touchCallback: (ev, resp) {
                                      if (resp != null && resp.touchedSection != null && ev is FlTapUpEvent) {
                                        final idx = resp.touchedSection!.touchedSectionIndex;
                                        final key = data.categories.keys.elementAt(idx);
                                        final val = data.categories[key]!;
                                        _showSlice(context, key, val);
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final e in data.categories.entries)
                                  _LegendItem(
                                    color: Colors.primaries[data.categories.keys.toList().indexOf(e.key) % Colors.primaries.length],
                                    label: '${e.key} • ${(e.value * 100).toStringAsFixed(0)}%',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: color.withOpacity(0.12),
        shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.4))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

void _showPoint(BuildContext context, ReportPoint pt) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Point', style: Theme.of(ctx).textTheme.titleLarge),
          Text('Date: ${pt.x}'),
          Text('Value: ${(pt.y * 100).toStringAsFixed(1)}%'),
        ],
      ),
    ),
  );
}

void _showSlice(BuildContext context, String key, double val) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category: $key', style: Theme.of(ctx).textTheme.titleLarge),
          Text('Share: ${(val * 100).toStringAsFixed(1)}%'),
        ],
      ),
    ),
  );
}
