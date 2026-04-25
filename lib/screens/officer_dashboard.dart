import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../complaint_store.dart';
import 'complaint_tracking.dart';
import 'login_screen.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final tasks = ComplaintStore.complaintsForOfficer();
    final inProgress = tasks.where((c) => c.status == 'In Progress').length;
    final pending = tasks.where((c) => c.status == 'Pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Officer Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplaintTrackingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.track_changes_rounded),
            tooltip: 'Open tracker',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10293F), Color(0xFF184E77), Color(0xFF0D6E8E)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Assigned Tasks',
                      value: '${tasks.length}',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF2B87D1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      title: 'In Progress',
                      value: '$inProgress',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFF08B2D),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      title: 'Pending',
                      value: '$pending',
                      icon: Icons.hourglass_bottom_rounded,
                      color: const Color(0xFFD84D4D),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'No assigned tasks right now.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final complaint = tasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${complaint.id} • ${complaint.issueType}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        complaint.status,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      complaint.status,
                                      style: TextStyle(
                                        color: _statusColor(complaint.status),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(complaint.description),
                              const SizedBox(height: 10),
                              Wrap(
                                runSpacing: 6,
                                spacing: 10,
                                children: [
                                  _chip('Dept: ${complaint.department}'),
                                  _chip(
                                    'Urgency: ${(complaint.urgencyScore * 100).toStringAsFixed(0)}%',
                                  ),
                                  _chip('ETA: ${complaint.estimatedHours}h'),
                                  _chip(
                                    'Officer: ${complaint.assignedOfficer}',
                                  ),
                                ],
                              ),
                              if (complaint.imagePath != null) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: kIsWeb
                                      ? Container(
                                          height: 120,
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
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openUpdateSheet(complaint),
                                  icon: const Icon(Icons.fact_check_rounded),
                                  label: const Text('Update Status & Evidence'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F609B),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _statusColor(String status) {
    if (status == 'Resolved') return const Color(0xFF2EAF63);
    if (status == 'In Progress') return const Color(0xFF2B87D1);
    if (status == 'Assigned') return const Color(0xFF8D6CE3);
    return const Color(0xFFF08B2D);
  }

  Future<void> _openUpdateSheet(Complaint complaint) async {
    String selectedStatus = complaint.status == 'Pending'
        ? 'Assigned'
        : complaint.status;
    String evidencePath = '';

    final noteController = TextEditingController();
    final officerController = TextEditingController(
      text: complaint.assignedOfficer == 'Unassigned'
          ? 'Officer On Duty'
          : complaint.assignedOfficer,
    );
    final etaController = TextEditingController(
      text: '${complaint.estimatedHours}',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update ${complaint.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Assigned',
                          child: Text('Assigned'),
                        ),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Resolved',
                          child: Text('Resolved'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedStatus = value;
                          if (selectedStatus == 'Resolved') {
                            etaController.text = '0';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: officerController,
                      decoration: const InputDecoration(
                        labelText: 'Officer Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Hours Remaining',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Completion Note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                        );
                        if (image == null) return;
                        setModalState(() {
                          evidencePath = image.path;
                        });
                      },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(
                        evidencePath.isEmpty
                            ? 'Upload evidence image'
                            : 'Evidence attached',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final note = noteController.text.trim().isEmpty
                              ? 'Task updated by officer.'
                              : noteController.text.trim();
                          final eta = int.tryParse(etaController.text.trim());

                          ComplaintStore.addComplaintUpdate(
                            complaintId: complaint.id,
                            status: selectedStatus,
                            note: note,
                            by: officerController.text.trim().isEmpty
                                ? 'Officer'
                                : officerController.text.trim(),
                            evidencePath: evidencePath.isEmpty
                                ? null
                                : evidencePath,
                            etaHours: eta,
                            assignedOfficer: officerController.text.trim(),
                          );

                          setState(() {});
                          Navigator.pop(context);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Task updated successfully.'),
                            ),
                          );
                        },
                        child: const Text('Save Update'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    noteController.dispose();
    officerController.dispose();
    etaController.dispose();
  }
}
