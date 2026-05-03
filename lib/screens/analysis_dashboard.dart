import 'package:flutter/material.dart';
import '../complaint_store.dart';
import '../services/firebase_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_city_insights.dart';
import 'complaint_tracking.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class AnalysisDashboardScreen extends StatelessWidget {
  const AnalysisDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Complaint>>(
      stream: FirebaseService.streamComplaints(),
      builder: (context, snapshot) {
        final liveComplaints = snapshot.data;
        if (liveComplaints != null) {
          ComplaintStore.complaints
            ..clear()
            ..addAll(liveComplaints);
        }

        final complaints = ComplaintStore.complaints;
        final total = complaints.length;
        final resolved = complaints.where((c) => c.status == "Resolved").length;
        final pending = complaints.where((c) => c.status != "Resolved").length;
        final high = complaints.where((c) => c.priority == "High").length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Analysis Dashboard",
              style: TextStyle(color: AppTheme.headingOnLight),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.mainHeadingDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.analytics_rounded,
                          color: Color(0xFF8FD3FF),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Live Complaint Intelligence",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.headingOnDark,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      summaryCard(
                        "$total",
                        "Total",
                        const Color(0xFF2B87D1),
                        Icons.assignment_rounded,
                      ),
                      summaryCard(
                        "$resolved",
                        "Resolved",
                        const Color(0xFF2EAF63),
                        Icons.task_alt_rounded,
                      ),
                      summaryCard(
                        "$pending",
                        "Pending",
                        const Color(0xFFF08B2D),
                        Icons.pending_actions_rounded,
                      ),
                      summaryCard(
                        "$high",
                        "High Priority",
                        const Color(0xFFD84D4D),
                        Icons.priority_high_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionCard(
                    title: "Complaints Overview",
                    child: buildPieChart(complaints),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: "Resolution Status",
                    child: buildBarChart(complaints),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: "Issue Categories",
                    child: Column(
                      children: [
                        categoryTile("Road Damage", Icons.construction, complaints),
                        categoryTile("Garbage", Icons.delete, complaints),
                        categoryTile("Street Light", Icons.lightbulb, complaints),
                        categoryTile("Water Leakage", Icons.water_drop, complaints),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
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
                      label: const Text("Open Complaint Tracking"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x80FFFFFF)),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AiCityInsightsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.psychology_alt_rounded),
                      label: const Text('Open AI Predictive Insights'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x80FFFFFF)),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= PIE CHART =================
  Widget buildPieChart(List complaints) {
    int road = complaints.where((c) => c.issueType == "Road Damage").length;
    int garbage = complaints.where((c) => c.issueType == "Garbage").length;
    int light = complaints.where((c) => c.issueType == "Street Light").length;

    int total = road + garbage + light;
    if (total == 0) total = 1; // avoid divide by zero

    return SizedBox(
      height: 230,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: road.toDouble(),
              color: const Color(0xFF2B87D1),
              title: "${((road / total) * 100).toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              value: garbage.toDouble(),
              color: const Color(0xFF2EAF63),
              title: "${((garbage / total) * 100).toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              value: light.toDouble(),
              color: const Color(0xFFF08B2D),
              title: "${((light / total) * 100).toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BAR CHART =================
  Widget buildBarChart(List complaints) {
    int pending = complaints.where((c) => c.status == "Pending").length;
    int resolved = complaints.where((c) => c.status == "Resolved").length;

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text("Pending");
                  if (value == 1) return const Text("Resolved");
                  return const Text("");
                },
              ),
            ),
          ),

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: pending.toDouble(),
                  color: const Color(0xFFF08B2D),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: resolved.toDouble(),
                  color: const Color(0xFF2EAF63),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget summaryCard(String number, String title, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  // ================= CATEGORY TILE =================
  Widget categoryTile(String type, IconData icon, List complaints) {
    int count = complaints.where((c) => c.issueType == type).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDECFB)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2B87D1)),
        title: Text(type),
        trailing: Text(
          "$count",
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.headingOnLight,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
