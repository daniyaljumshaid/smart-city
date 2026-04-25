import 'package:flutter/material.dart';
import '../complaint_store.dart';
import 'analysis_dashboard.dart';
import 'report_issue.dart';
import 'location_screen.dart';
import 'emergency_screen.dart';
import 'community_section.dart';
import 'notifications_screen.dart';
import 'ai_city_insights.dart';
import 'login_screen.dart';
import 'my_complaints_screen.dart';

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final recentComplaints = ComplaintStore.complaints.take(3).toList();
    final total = ComplaintStore.complaints.length;
    final active = ComplaintStore.complaints
        .where((complaint) => complaint.status != 'Resolved')
        .length;
    final resolved = ComplaintStore.complaints
        .where((complaint) => complaint.status == 'Resolved')
        .length;
    final unreadCitizen = ComplaintStore.notifications
        .where(
          (notification) =>
              notification.targetRole == UserRole.citizen &&
              !notification.isRead,
        )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(
            color: Color(0xFF10283E),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const NotificationsScreen(role: UserRole.citizen),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, color: Colors.black),
              ),
              if (unreadCitizen > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD94D4D),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCitizen > 9 ? '9+' : '$unreadCitizen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F9FF), Color(0xFFEAF3FF), Color(0xFFF8FBFF)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10314D), Color(0xFF155C8B)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2A1B4B70),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back, Citizen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Report issues, track progress, and navigate city services quickly.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _statPill(
                            'Total',
                            '$total',
                            const Color(0xFF8FD3FF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statPill(
                            'Active',
                            '$active',
                            const Color(0xFFFFCB77),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statPill(
                            'Resolved',
                            '$resolved',
                            const Color(0xFF9CE7AE),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search complaints, areas, categories...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16344D),
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.16,
                children: [
                  dashboardCard(
                    context,
                    icon: Icons.report_problem_rounded,
                    title: 'Report Issue',
                    subtitle: 'Create a new civic complaint',
                    color: const Color(0xFFD84D4D),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportIssueScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.assignment_rounded,
                    title: 'My Complaints',
                    subtitle: 'Pending, active, resolved',
                    color: const Color(0xFF2B87D1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyComplaintsScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.map_rounded,
                    title: 'Map Location',
                    subtitle: 'Pin and share issue points',
                    color: const Color(0xFF1FA6C2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.analytics_rounded,
                    title: 'Analysis Screen',
                    subtitle: 'View trends and metrics',
                    color: const Color(0xFF7A56C2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalysisDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.emergency_share_rounded,
                    title: 'Emergency',
                    subtitle: 'Send SOS and quick response',
                    color: const Color(0xFFD84D4D),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.groups_2_rounded,
                    title: 'Community',
                    subtitle: 'Polls and city discussion',
                    color: const Color(0xFF2EAF63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CommunitySectionScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Case updates and alerts',
                    color: const Color(0xFF0F609B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationsScreen(role: UserRole.citizen),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.psychology_alt_rounded,
                    title: 'AI Insights',
                    subtitle: 'Predicted risk and trends',
                    color: const Color(0xFF0E9A6C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiCityInsightsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Complaints',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16344D),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyComplaintsScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              if (recentComplaints.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No complaints yet. Use Report Issue to submit your first case.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ...recentComplaints.map(
                (complaint) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: complaintCard(
                    title: complaint.issueType,
                    location: complaint.location,
                    status: complaint.status,
                    icon: Icons.report_problem_rounded,
                    color: _statusColor(complaint.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF0F609B),
        unselectedItemColor: const Color(0xFF7B8DA0),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocationScreen()),
            );
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyComplaintsScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'My Complaints',
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'Resolved') return Colors.green;
    if (status == 'In Progress') return Colors.blue;
    if (status == 'Assigned') return Colors.purple;
    return Colors.orange;
  }

  Widget dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE5F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, size: 20, color: color),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5A7288),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, String value, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFE1EEF9), fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget complaintCard({
    required String title,
    required String location,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E1EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(color: Color(0xFF5A7288)),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
