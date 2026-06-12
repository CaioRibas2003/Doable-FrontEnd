import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/stats_controller.dart';
import '../models/stats_model.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<StatsController>(context, listen: false).load(),
    );
  }

  Color _hexToColor(String hex) =>
      Color(int.parse(hex.replaceAll('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: Consumer<StatsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null || controller.stats == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(controller.errorMessage ?? 'Sem dados'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.load,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final stats = controller.stats!;

          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                Row(
                  children: [
                    _SummaryCard(
                      label: '7 dias',
                      value: stats.completedLast7Days,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _SummaryCard(
                      label: '15 dias',
                      value: stats.completedLast15Days,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _SummaryCard(
                      label: '30 dias',
                      value: stats.completedLast30Days,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                
                const Text(
                  'Tasks concluídas por dia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Seletor de período
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7d')),
                    ButtonSegment(value: 15, label: Text('15d')),
                    ButtonSegment(value: 30, label: Text('30d')),
                  ],
                  selected: {controller.selectedPeriod},
                  onSelectionChanged: (v) => controller.setPeriod(v.first),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _LineChart(
                    dailyMap: controller.currentDailyMap,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                
                if (stats.completionsByTag.isNotEmpty) ...[
                  const Text(
                    'Concluídas por tag (últimos 30 dias)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: _TagBarChart(
                      tagStats: stats.completionsByTag,
                      hexToColor: _hexToColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                
                if (stats.goalsProgress.isNotEmpty) ...[
                  const Text(
                    'Metas ativas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...stats.goalsProgress.map(
                    (goal) => _GoalProgressCard(
                      goal: goal,
                      hexToColor: _hexToColor,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}



class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}



class _LineChart extends StatelessWidget {
  final Map<String, int> dailyMap;
  final Color color;

  const _LineChart({required this.dailyMap, required this.color});

  @override
  Widget build(BuildContext context) {
    if (dailyMap.isEmpty) {
      return const Center(child: Text('Sem dados no período'));
    }

    final entries = dailyMap.entries.toList();
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    final maxY = (dailyMap.values.fold(0, (a, b) => a > b ? a : b) + 1)
        .toDouble()
        .clamp(3.0, double.infinity);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: entries.length <= 7
                  ? 1
                  : entries.length <= 15
                      ? 3
                      : 5,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox();
                final parts = entries[idx].key.split('-');
                return Text(
                  '${parts[2]}/${parts[1]}',
                  style: const TextStyle(fontSize: 9),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeColor: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}



class _TagBarChart extends StatelessWidget {
  final List<TagStat> tagStats;
  final Color Function(String) hexToColor;

  const _TagBarChart({required this.tagStats, required this.hexToColor});

  @override
  Widget build(BuildContext context) {
    final maxY = (tagStats.map((t) => t.completedCount).fold(0, (a, b) => a > b ? a : b) + 1)
        .toDouble()
        .clamp(3.0, double.infinity);

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= tagStats.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tagStats[idx].tagName.length > 6
                        ? '${tagStats[idx].tagName.substring(0, 6)}…'
                        : tagStats[idx].tagName,
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: tagStats.asMap().entries.map((e) {
          final color = hexToColor(e.value.tagColor);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.completedCount.toDouble(),
                color: color,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}



class _GoalProgressCard extends StatelessWidget {
  final dynamic goal;
  final Color Function(String) hexToColor;

  const _GoalProgressCard({required this.goal, required this.hexToColor});

  @override
  Widget build(BuildContext context) {
    final progress = ((goal.progressPercent ?? 0) / 100).clamp(0.0, 1.0);
    final achieved = goal.achieved ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (achieved)
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              goal.tagName != null
                  ? 'Tag: ${goal.tagName} · ${goal.periodDays} dias'
                  : '${goal.periodDays} dias',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achieved ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${goal.currentCount ?? 0}/${goal.targetCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: achieved ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}