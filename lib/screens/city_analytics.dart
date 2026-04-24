import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../complaint_store.dart';
import 'analysis_dashboard.dart';
import 'complaint_tracking.dart';

class CityAnalyticsScreen extends StatelessWidget {
  const CityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = ComplaintStore.complaints;
    final total = complaints.length;
    final resolved = complaints.where((c) => c.status == 'Resolved').length;
    final pending = (total - resolved).clamp(0, total);
    final road = complaints.where((c) => c.issueType == 'Road Damage').length;
    final garbage = complaints.where((c) => c.issueType == 'Garbage').length;
    final utilities = complaints.where((c) => c.issueType == 'Street Light').length;
    final infrastructure = complaints.where((c) => c.priority == 'High').length;
    final under24h = (resolved * 0.72).round();
    final over24h = resolved - under24h;

    return Scaffold(
      appBar: AppBar(
        title: const Text('City Analytics'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2A43), Color(0xFF184E77), Color(0xFF1D6FA5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.query_stats_rounded, color: Color(0xFF0E5A92), size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Analytics Overview and Area Trends',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF14324A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  title: 'ISSUE TYPE STATISTICS',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 170,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  barGroups: [
                                    _bar(0, road.toDouble(), const Color(0xFF2B87D1)),
                                    _bar(1, garbage.toDouble(), const Color(0xFF2EAF63)),
                                    _bar(2, utilities.toDouble(), const Color(0xFFF08B2D)),
                                    _bar(3, infrastructure.toDouble(), const Color(0xFFD84D4D)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.bar_chart_rounded, size: 30, color: Color(0xFF0E5A92)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Traffic'),
                          Text('Waste'),
                          Text('Utilities'),
                          Text('Infrastructure'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  title: 'Most Reported Areas',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 140,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFEDD6), Color(0xFFFFD3A3), Color(0xFFFFB477)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: GridView.count(
                                crossAxisCount: 4,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(
                                  12,
                                  (index) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Color.lerp(
                                        const Color(0xFFFFE3BE),
                                        const Color(0xFFFF7C3F),
                                        index / 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 72,
                            child: Text(
                              'Heatmap\nGraph',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Downtown'),
                          Text('Central Park'),
                          Text('North River'),
                          Text('East End'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  title: 'Resolution Performance',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 170,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      isCurved: true,
                                      color: const Color(0xFF0E5A92),
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF0E5A92).withValues(alpha: 0.15),
                                      ),
                                      dotData: const FlDotData(show: false),
                                      spots: [
                                        FlSpot(0, (pending + 1).toDouble()),
                                        FlSpot(1, (pending * 0.8 + 1).toDouble()),
                                        FlSpot(2, (pending * 0.6 + 1).toDouble()),
                                        FlSpot(3, (pending * 0.35 + 1).toDouble()),
                                        FlSpot(4, (over24h + 1).toDouble()),
                                        FlSpot(5, (under24h + 1).toDouble()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.show_chart_rounded, size: 30, color: Color(0xFF0E5A92)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('Time to Resolve'),
                          Text('Over 24h: $over24h'),
                          Text('Under 24h: $under24h'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.96),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Complaints: $total',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Resolved Complaints: $resolved',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AnalysisDashboardScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.analytics_rounded),
                              label: const Text('Detailed Analysis'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F609B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ComplaintTrackingScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.track_changes_rounded),
                              label: const Text('Tracking'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E384D),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y <= 0 ? 0.4 : y,
          color: color,
          width: 14,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}
