import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../complaint_store.dart';
import 'complaint_tracking.dart';
import 'location_screen.dart';
import 'notifications_screen.dart';
import 'report_issue.dart';
import '../theme/app_theme.dart';

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
    final allComplaints = ComplaintStore.complaints;
    final complaints = _applyFilter(allComplaints);
    final counts = _countsByFilter(allComplaints);
    final lastUpdated = _latestUpdateAt(allComplaints);
    final unreadCount = ComplaintStore.unreadNotificationCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Citizen: My Complaints',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
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
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_active_outlined),
                Positioned(
                  top: -3,
                  right: -4,
                  child: _notificationBadge(unreadCount),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.lightGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titlePanel(),
                const SizedBox(height: 12),
                _summaryPanel(
                  counts: counts,
                  visibleCount: complaints.length,
                  lastUpdated: lastUpdated,
                ),
                const SizedBox(height: 16),
                _sectionHeader(
                  'Filter complaints',
                  subtitle: _filterLabel(_selectedFilter),
                ),
                const SizedBox(height: 10),
                _filterRow(),
                const SizedBox(height: 16),
                _sectionHeader(
                  'Complaints',
                  subtitle: '${complaints.length} visible',
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: complaints.isEmpty
                      ? _emptyState()
                      : Column(
                          key: ValueKey(_selectedFilter),
                          children: complaints
                              .map(
                                (complaint) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _complaintCard(context, complaint),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: _reportButton(context),
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

  Map<ComplaintFilter, int> _countsByFilter(List<Complaint> source) {
    var pending = 0;
    var active = 0;
    var resolved = 0;

    for (final complaint in source) {
      if (complaint.status == 'Pending') {
        pending += 1;
      } else if (complaint.status == 'Assigned' ||
          complaint.status == 'In Progress') {
        active += 1;
      } else if (complaint.status == 'Resolved') {
        resolved += 1;
      }
    }

    return {
      ComplaintFilter.all: source.length,
      ComplaintFilter.pending: pending,
      ComplaintFilter.active: active,
      ComplaintFilter.resolved: resolved,
    };
  }

  DateTime? _latestUpdateAt(List<Complaint> source) {
    if (source.isEmpty) return null;
    var latest = source.first.updatedAt;
    for (final complaint in source.skip(1)) {
      if (complaint.updatedAt.isAfter(latest)) {
        latest = complaint.updatedAt;
      }
    }
    return latest;
  }

  String _filterLabel(ComplaintFilter filter) {
    switch (filter) {
      case ComplaintFilter.all:
        return 'All complaints';
      case ComplaintFilter.pending:
        return 'Pending only';
      case ComplaintFilter.active:
        return 'Active only';
      case ComplaintFilter.resolved:
        return 'Resolved only';
    }
  }

  Widget _notificationBadge(int count) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE04646),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.headingOnLight,
            ),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF5B7086),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _summaryPanel({
    required Map<ComplaintFilter, int> counts,
    required int visibleCount,
    required DateTime? lastUpdated,
  }) {
    final total = counts[ComplaintFilter.all] ?? 0;
    final pending = counts[ComplaintFilter.pending] ?? 0;
    final active = counts[ComplaintFilter.active] ?? 0;
    final resolved = counts[ComplaintFilter.resolved] ?? 0;
    final statusLine = total == 0
        ? 'No complaints submitted yet.'
        : 'Showing $visibleCount of $total (${_filterLabel(_selectedFilter)}).';
    final updateLine = lastUpdated == null
        ? 'No updates yet.'
        : 'Last update ${_timeAgo(lastUpdated)}.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.headingOnLight,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryChip('All', total, const Color(0xFF102D45)),
              _summaryChip('Active', active, const Color(0xFF265A8F)),
              _summaryChip('Pending', pending, const Color(0xFFB06E04)),
              _summaryChip('Resolved', resolved, const Color(0xFF1C8C45)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            statusLine,
            style: const TextStyle(
              color: Color(0xFF3E5064),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(updateLine, style: const TextStyle(color: Color(0xFF6A7F94))),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _priorityPill(String priority) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        priority,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  IconData _statusIcon(String status) {
    return AppTheme.statusIcon(status);
  }

  // ── UPDATED: blue background, white text ──
  Widget _titlePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.mainHeadingDecoration(),
      child: const Text(
        'MY COMPLAINTS',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: AppTheme.headingOnDark,
        ),
      ),
    );
  }

  Widget _filterRow() {
    return Semantics(
      label: 'Filter complaints',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _filterChip(ComplaintFilter.all, 'All'),
          _filterChip(ComplaintFilter.pending, 'Pending'),
          _filterChip(ComplaintFilter.active, 'Active'),
          _filterChip(ComplaintFilter.resolved, 'Resolved'),
        ],
      ),
    );
  }

  Widget _filterChip(ComplaintFilter value, String label) {
    final selected = _selectedFilter == value;
    return Tooltip(
      message: 'Show $label complaints',
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = value;
          });
        },
        showCheckmark: false,
        selectedColor: const Color(0xFF102D45),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF2D3E50),
        ),
        side: BorderSide(
          color: selected ? const Color(0xFF102D45) : const Color(0xFFC7D1DE),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final canTrack = complaint.location.trim().isNotEmpty;
    final officerLabel = complaint.assignedOfficer.trim().isEmpty
        ? 'Unassigned'
        : complaint.assignedOfficer.trim();

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
              _statusPill(complaint.status),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '#${_shortId(complaint.id)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A4C60),
                ),
              ),
              const SizedBox(width: 8),
              _priorityPill(complaint.priority),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF3B4F63)),
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
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.apartment, size: 18, color: Color(0xFF617A90)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Department: ${complaint.department}',
                  style: const TextStyle(
                    color: Color(0xFF4D6075),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 18,
                color: Color(0xFF617A90),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Officer: $officerLabel',
                  style: const TextStyle(
                    color: Color(0xFF4D6075),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (complaint.imagePath != null) ...[
            const SizedBox(height: 12),
            Semantics(
              label: 'Complaint photo preview',
              child: ClipRRect(
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
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFF7F9FC),
              border: Border(left: BorderSide(width: 3, color: statusColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _statusIcon(complaint.status),
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Status: ${complaint.status}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: statusColor,
                      ),
                    ),
                  ],
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
              child: OutlinedButton.icon(
                onPressed: canTrack
                    ? () async {
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
                          SnackBar(
                            content: Text('Location updated to: $result'),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.map_outlined),
                label: const Text(
                  'Track Live on Map',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9FAFC2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: const Color(0xFF1F3348),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (!canTrack) ...[
              const SizedBox(height: 6),
              const Text(
                'Add a location to enable live tracking.',
                style: TextStyle(color: Color(0xFF6A7F94)),
              ),
            ],
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
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 36, color: Color(0xFF5C7187)),
          const SizedBox(height: 8),
          const Text(
            'No complaints found for this filter.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different filter or report a new issue.',
            style: TextStyle(color: Color(0xFF5B7086)),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _selectedFilter == ComplaintFilter.all
                ? null
                : () {
                    setState(() {
                      _selectedFilter = ComplaintFilter.all;
                    });
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Show all complaints'),
          ),
        ],
      ),
    );
  }

  Widget _reportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
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
        icon: const Icon(Icons.report_outlined),
        label: const Text(
          'Report new issue',
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

  Color _priorityColor(String priority) {
    return AppTheme.priorityColor(priority);
  }

  Color _statusColor(String status) {
    return AppTheme.statusColor(status);
  }

  String _shortId(String id) {
    final onlyDigits = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return id;
    if (onlyDigits.length <= 4) return onlyDigits;
    return onlyDigits.substring(onlyDigits.length - 4);
  }
}
