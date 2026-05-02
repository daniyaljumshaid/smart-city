import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../complaint_store.dart';
import 'location_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'report_issue.dart';
import '../theme/app_theme.dart';

class ComplaintTrackingScreen extends StatelessWidget {
  const ComplaintTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = ComplaintStore.complaints;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Complaint Tracking",
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
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
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssueScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Report issue',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: complaints.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.mainHeadingDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_rounded,
                        size: 44,
                        color: Color(0xFF8FD3FF),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No Complaints Submitted Yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.headingOnDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Submit a complaint to start tracking progress.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFE8EEF3)),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportIssueScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.report_problem_outlined),
                          label: const Text('Report an Issue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F609B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];

                  Color priorityColor;
                  if (complaint.priority == "High") {
                    priorityColor = AppTheme.priorityColor('High');
                  } else if (complaint.priority == "Medium") {
                    priorityColor = AppTheme.priorityColor('Medium');
                  } else {
                    priorityColor = AppTheme.priorityColor('Low');
                  }

                  Color statusColor;
                  if (complaint.status == "Resolved") {
                    statusColor = AppTheme.statusColor('Resolved');
                  } else if (complaint.status == "In Progress") {
                    statusColor = AppTheme.statusColor('In Progress');
                  } else {
                    statusColor = AppTheme.statusColor('Pending');
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: priorityColor.withOpacity(0.15),
                              child: Icon(
                                Icons.report_problem,
                                color: priorityColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                complaint.issueType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                complaint.priority,
                                style: TextStyle(
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          complaint.description,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                complaint.location,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationScreen(
                                      initialLocationText: complaint.location,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.map_rounded,
                                size: 20,
                                color: Color(0xFF0F609B),
                              ),
                              tooltip: 'Open on map',
                            ),
                          ],
                        ),
                        if (complaint.imagePath != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: const Color(0xFFF2F7FE),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Image preview is supported on mobile/desktop apps.',
                                      style: TextStyle(
                                        color: Color(0xFF4F677A),
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(complaint.imagePath!),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: const Color(0xFFF2F7FE),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Unable to load uploaded complaint image.',
                                          style: TextStyle(
                                            color: Color(0xFF4F677A),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _metaChip('Dept: ${complaint.department}'),
                            _metaChip('Officer: ${complaint.assignedOfficer}'),
                            _metaChip('ETA: ${complaint.estimatedHours}h'),
                            _metaChip(
                              'Urgency: ${(complaint.urgencyScore * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                complaint.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            'Progress Timeline',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          children: complaint.updates
                              .map(
                                (update) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.fiber_manual_record,
                                    size: 12,
                                    color: statusColor,
                                  ),
                                  title: Text(update.status),
                                  subtitle: Text(
                                    '${update.note}\nBy: ${update.by}',
                                  ),
                                  trailing: update.evidencePath == null
                                      ? null
                                      : const Icon(
                                          Icons.image_rounded,
                                          color: Color(0xFF0F609B),
                                        ),
                                ),
                              )
                              .toList(),
                        ),
                        ...complaint.updates
                            .where((update) => update.evidencePath != null)
                            .take(1)
                            .map(
                              (update) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: kIsWeb
                                      ? Container(
                                          height: 120,
                                          width: double.infinity,
                                          color: const Color(0xFFF2F7FE),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Evidence preview on mobile/desktop apps.',
                                            style: TextStyle(
                                              color: Color(0xFF4F677A),
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          File(update.evidencePath!),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return Container(
                                              height: 120,
                                              width: double.infinity,
                                              color: const Color(0xFFF2F7FE),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Unable to load evidence image.',
                                                style: TextStyle(
                                                  color: Color(0xFF4F677A),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
