import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../complaint_store.dart';
import 'complaint_tracking.dart';
import 'location_screen.dart';
import 'notifications_screen.dart';
import 'report_issue.dart';

enum ComplaintFilter { all, pending, active, resolved }

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  ComplaintFilter _selectedFilter = ComplaintFilter.all;

  @override
  Widget build(BuildContext context) {
    final complaints = _applyFilter(ComplaintStore.complaints);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen: My Complaints'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Open detailed tracking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplaintTrackingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.track_changes_rounded, color: Colors.black),
          ),
          IconButton(
            tooltip: 'Notifications',
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
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4F8FC), Color(0xFFEAF2FB), Color(0xFFF8FBFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titlePanel(),
              const SizedBox(height: 14),
              _filterRow(),
              const SizedBox(height: 16),
              if (complaints.isEmpty)
                _emptyState()
              else
                ...complaints.map(
                  (complaint) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _complaintCard(context, complaint),
                  ),
                ),
              const SizedBox(height: 8),
              _reportButton(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Complaint> _applyFilter(List<Complaint> source) {
    final filtered = source.where((complaint) {
      switch (_selectedFilter) {
        case ComplaintFilter.pending:
          return complaint.status == 'Pending';
        case ComplaintFilter.active:
          return complaint.status == 'Assigned' ||
              complaint.status == 'In Progress';
        case ComplaintFilter.resolved:
          return complaint.status == 'Resolved';
        case ComplaintFilter.all:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Widget _titlePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: const Text(
        'MY COMPLAINTS',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
      ),
    );
  }

  Widget _filterRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _filterChip(ComplaintFilter.all, 'All'),
        _filterChip(ComplaintFilter.pending, 'Pending'),
        _filterChip(ComplaintFilter.active, 'Active'),
        _filterChip(ComplaintFilter.resolved, 'Resolved'),
      ],
    );
  }

  Widget _filterChip(ComplaintFilter value, String label) {
    final selected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 84),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF102D45) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF102D45) : const Color(0xFFC7D1DE),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF2D3E50),
          ),
        ),
      ),
    );
  }

  Widget _complaintCard(BuildContext context, Complaint complaint) {
    final statusColor = _statusColor(complaint.status);
    final latestUpdate = complaint.updates.isNotEmpty
        ? complaint.updates.first
        : ComplaintUpdate(
            status: complaint.status,
            note: 'No officer note yet.',
            by: 'System',
            createdAt: complaint.createdAt,
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DEE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.issueType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
              ),
              Text(
                '#${_shortId(complaint.id)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A4C60),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              const Icon(Icons.location_pin, size: 19, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  complaint.location,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2A3E53),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF617A90)),
              const SizedBox(width: 6),
              Text(
                'Reported: ${_timeAgo(complaint.createdAt)}',
                style: const TextStyle(
                  color: Color(0xFF4D6075),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (complaint.imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Container(
                      height: 140,
                      width: double.infinity,
                      color: const Color(0xFFF2F7FE),
                      alignment: Alignment.center,
                      child: const Text(
                        'Uploaded image available on app devices.',
                        style: TextStyle(color: Color(0xFF4F677A)),
                      ),
                    )
                  : Image.file(
                      File(complaint.imagePath!),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: const Color(0xFFF2F7FE),
                          alignment: Alignment.center,
                          child: const Text(
                            'Could not open uploaded image.',
                            style: TextStyle(color: Color(0xFF4F677A)),
                          ),
                        );
                      },
                    ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFF7F9FC),
              border: const Border(
                left: BorderSide(width: 3, color: Colors.black),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${complaint.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  complaint.status == 'Resolved'
                      ? 'Fixed on: ${_formatDate(complaint.updatedAt)}'
                      : 'Est. Resolution: ${_etaLabel(complaint.estimatedHours)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B3E53),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Officer Note: "${latestUpdate.note}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4A5E73),
                  ),
                ),
              ],
            ),
          ),
          if (complaint.status != 'Resolved') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationScreen(
                        initialLocationText: complaint.location,
                      ),
                    ),
                  );

                  if (result == null || !context.mounted) return;
                  setState(() {
                    complaint.location = result as String;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tracking map opened: $result')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9FAFC2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: const Color(0xFF1F3348),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Track Live on Map',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DEE8)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_rounded, size: 36, color: Color(0xFF5C7187)),
          SizedBox(height: 8),
          Text(
            'No complaints found for this filter.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _reportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF102D45),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '+ REPORT NEW ISSUE',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _etaLabel(int hours) {
    if (hours <= 18) return 'Today';
    if (hours <= 42) return 'Tomorrow';
    final days = (hours / 24).ceil();
    return '$days day${days == 1 ? '' : 's'}';
  }

  Color _statusColor(String status) {
    if (status == 'Resolved') return const Color(0xFF1C8C45);
    if (status == 'In Progress') return const Color(0xFF956700);
    if (status == 'Assigned') return const Color(0xFF265A8F);
    return const Color(0xFFB06E04);
  }

  String _shortId(String id) {
    final onlyDigits = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return id;
    if (onlyDigits.length <= 4) return onlyDigits;
    return onlyDigits.substring(onlyDigits.length - 4);
  }
}
