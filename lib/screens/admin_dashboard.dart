import 'package:flutter/material.dart';

import '../complaint_store.dart';
import 'ai_city_insights.dart';
import 'city_analytics.dart';
import 'complaint_tracking.dart';
import 'login_screen.dart';
import 'officer_dashboard.dart';
import '../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ComplaintStore.complaints;
    final total = complaints.length;
    final resolved = complaints.where((c) => c.status == 'Resolved').length;
    final resolvedRate = total == 0 ? 0 : ((resolved / total) * 100).round();
    final avgFixTime = _averageFixHours(complaints);
    final departmentStats = _departmentPerformance(complaints);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.black),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 880;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleStrip(),
                const SizedBox(height: 12),
                _headerBar(),
                const SizedBox(height: 12),
                _tabStrip(context),
                const SizedBox(height: 14),
                if (_searchQuery.isNotEmpty) ...[
                  _searchResultsCard(_matchingComplaints(_searchQuery)),
                  const SizedBox(height: 14),
                ],
                if (isNarrow) ...[
                  _cityOverviewCard(
                    total: total,
                    resolvedRate: resolvedRate,
                    avgFixTime: avgFixTime,
                  ),
                  const SizedBox(height: 10),
                  _aiInsightsCard(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _cityOverviewCard(
                          total: total,
                          resolvedRate: resolvedRate,
                          avgFixTime: avgFixTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _aiInsightsCard()),
                    ],
                  ),
                const SizedBox(height: 14),
                if (isNarrow) ...[
                  _heatMapCard(context),
                  const SizedBox(height: 10),
                  _departmentCard(departmentStats),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _heatMapCard(context)),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: _departmentCard(departmentStats),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _titleStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.mainHeadingDecoration(),
      child: const Text(
        '5. Admin: Main Dashboard',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 21,
          color: AppTheme.headingOnDark,
        ),
      ),
    );
  }

  Widget _headerBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART CITY',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: AppTheme.primary,
                  ),
                ),
                const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search complaints, departments, users...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 13),
                      cursorColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDCF7)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabStrip(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _tabButton(label: 'Overview', active: true, onTap: () {}),
          _tabButton(
            label: 'Complaints',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplaintTrackingScreen(),
                ),
              );
            },
          ),
          _tabButton(
            label: 'Departments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfficerDashboardScreen(),
                ),
              );
            },
          ),
          _tabButton(
            label: 'AI Insights',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiCityInsightsScreen(),
                ),
              );
            },
          ),
          _tabButton(
            label: 'Users',
            onTap: () {
              _showUsersModal(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : const Color(0xFFF6FAFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppTheme.primary : const Color(0xFFD1DCE7),
            width: active ? 2 : 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: active ? Colors.white : const Color(0xFF3F5B7B),
          ),
        ),
      ),
    );
  }

  Widget _cityOverviewCard({
    required int total,
    required int resolvedRate,
    required int avgFixTime,
  }) {
    return _wirePanel(
      title: 'CITY OVERVIEW',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Issues: $total', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 5),
          Text(
            'Resolved: $resolvedRate%',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            'Avg Fix Time: ${avgFixTime} hrs',
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _aiInsightsCard() {
    return _wirePanel(
      title: 'AI PREDICTIONS & INSIGHTS',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightRow(
            icon: Icons.warning_amber_rounded,
            text: 'High accident zone detected in Sector 4.',
          ),
          SizedBox(height: 8),
          _InsightRow(
            icon: Icons.water_drop_rounded,
            text: 'Water leakage trend rising in Downtown.',
          ),
        ],
      ),
    );
  }

  Widget _heatMapCard(BuildContext context) {
    return _wirePanel(
      title: 'COMPLAINT HEAT MAP',
      child: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF0DB),
                  Color(0xFFFFE0BF),
                  Color(0xFFFFD0A3),
                ],
              ),
              border: Border.all(color: const Color(0xFFE2B78B)),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  itemCount: 49,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final intensity = (index % 9) / 8;
                    return Container(
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFFFFE3BF),
                          const Color(0xFFFF6D2D),
                          intensity,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
                const Center(
                  child: Text(
                    '[ Map showing high-density issue areas ]',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5D3E26),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CityAnalyticsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded),
              label: const Text('Open City Analytics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F609B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentCard(List<_DepartmentStat> stats) {
    return _wirePanel(
      title: 'DEPARTMENT PERFORMANCE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < stats.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == stats.length - 1 ? 0 : 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Text(
                      '${stats[i].label}: ${stats[i].score}% Resolution Rate',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (stats[i].alert)
                    const Icon(
                      Icons.notifications_active_rounded,
                      size: 18,
                      color: Color(0xFFB8860B),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _wirePanel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFCAD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.headingOnLight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  List<Complaint> _matchingComplaints(String query) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return [];

    return ComplaintStore.complaints.where((complaint) {
      return complaint.id.toLowerCase().contains(lower) ||
          complaint.issueType.toLowerCase().contains(lower) ||
          complaint.description.toLowerCase().contains(lower) ||
          complaint.location.toLowerCase().contains(lower) ||
          complaint.department.toLowerCase().contains(lower) ||
          complaint.citizenName.toLowerCase().contains(lower) ||
          complaint.status.toLowerCase().contains(lower);
    }).toList();
  }

  Widget _searchResultsCard(List<Complaint> results) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            const Text(
              'No matching complaints found. Try a different keyword.',
              style: TextStyle(color: Color(0xFF526277)),
            )
          else
            Column(
              children: results
                  .map(
                    (complaint) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FBFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7E7F4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${complaint.id} • ${complaint.issueType}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            complaint.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF526277)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${complaint.department} • ${complaint.status} • ${complaint.citizenName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8AA0B1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  int _averageFixHours(List<Complaint> complaints) {
    if (complaints.isEmpty) return 0;
    final total = complaints.fold<int>(
      0,
      (sum, complaint) => sum + complaint.estimatedHours,
    );
    return (total / complaints.length).round();
  }

  List<_DepartmentStat> _departmentPerformance(List<Complaint> complaints) {
    int scoreFor(String keyword, int fallback) {
      final bucket = complaints
          .where(
            (complaint) => complaint.department.toLowerCase().contains(keyword),
          )
          .toList();

      if (bucket.isEmpty) return fallback;

      final resolved = bucket
          .where((complaint) => complaint.status == 'Resolved')
          .length;
      if (resolved == 0) return fallback;

      return ((resolved / bucket.length) * 100).round().clamp(60, 98);
    }

    return [
      _DepartmentStat(label: 'Water Dept', score: scoreFor('water', 92)),
      _DepartmentStat(label: 'Waste Mgmt', score: scoreFor('waste', 88)),
      _DepartmentStat(
        label: 'Road Auth',
        score: scoreFor('road', 75),
        alert: true,
      ),
    ];
  }

  void _showUsersModal(BuildContext context) {
    final complaints = ComplaintStore.complaints;
    final citizens = <String>{};
    final officers = <String>{};

    for (var complaint in complaints) {
      citizens.add(complaint.citizenName);
      if (complaint.assignedOfficer != 'Unassigned') {
        officers.add(complaint.assignedOfficer);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Users'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Citizens:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (citizens.isEmpty)
                  const Text('No citizens found')
                else
                  ...citizens.map(
                    (citizen) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('• $citizen'),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Government Officers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (officers.isEmpty)
                  const Text('No officers assigned')
                else
                  ...officers.map(
                    (officer) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('• $officer'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0E5A92)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _DepartmentStat {
  const _DepartmentStat({
    required this.label,
    required this.score,
    this.alert = false,
  });

  final String label;
  final int score;
  final bool alert;
}
