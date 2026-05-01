import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'location_screen.dart';
import '../complaint_store.dart';
import '../services/ai_engine.dart';
import 'my_complaints_screen.dart';
import '../theme/app_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _citizenNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedIssue = 'Auto Detect';
  String _selectedPriority = 'AI Recommended';
  String _locationText = 'Not Selected';
  String _photoPath = '';
  AiClassificationResult? _analysis;

  bool get _canSubmit {
    return _locationText != 'Not Selected' &&
        _descriptionController.text.trim().isNotEmpty;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
    );

    if (image == null) return;

    setState(() {
      _photoPath = image.path;
    });
  }

  void _runAiClassification() {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      showError('Please enter complaint description for AI analysis.');
      return;
    }

    final result = SmartCityAiEngine.classifyComplaint(
      description: text,
      selectedCategory: _selectedIssue == 'Auto Detect' ? null : _selectedIssue,
    );

    setState(() {
      _analysis = result;
      if (_selectedPriority == 'AI Recommended') {
        _selectedPriority = 'AI Recommended';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI classification completed.')),
    );
  }

  int _etaWithPriority(AiClassificationResult result, String priority) {
    if (priority == result.priority) return result.etaHours;
    if (priority == 'High') return (result.etaHours * 0.70).round();
    if (priority == 'Medium') return result.etaHours;
    return (result.etaHours * 1.45).round();
  }

  void _submitComplaint() {
    if (_locationText == 'Not Selected') {
      showError('Please select location');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      showError('Please enter complaint description');
      return;
    }

    final aiResult =
        _analysis ??
        SmartCityAiEngine.classifyComplaint(
          description: _descriptionController.text.trim(),
          selectedCategory: _selectedIssue == 'Auto Detect'
              ? null
              : _selectedIssue,
        );

    final finalPriority = _selectedPriority == 'AI Recommended'
        ? aiResult.priority
        : _selectedPriority;

    final complaint = Complaint(
      citizenName: _citizenNameController.text.trim().isEmpty
          ? 'Citizen'
          : _citizenNameController.text.trim(),
      issueType: aiResult.category,
      description: _descriptionController.text.trim(),
      priority: finalPriority,
      location: _locationText,
      status: 'Pending',
      urgencyScore: aiResult.urgencyScore,
      department: aiResult.department,
      assignedOfficer: '${aiResult.department} Queue',
      estimatedHours: _etaWithPriority(aiResult, finalPriority),
      imagePath: _photoPath.isEmpty ? null : _photoPath,
      updates: [
        ComplaintUpdate(
          status: 'Pending',
          note: aiResult.reasoning,
          by: 'System AI',
        ),
      ],
    );

    ComplaintStore.addComplaint(complaint);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Complaint ${complaint.id} submitted and auto-assigned to ${complaint.department}.',
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyComplaintsScreen()),
    );
  }

  @override
  void dispose() {
    _citizenNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Complaint Reporting',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _runAiClassification,
            icon: const Icon(Icons.psychology_alt_rounded),
            label: const Text('Analyze'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Complaint & Issue Reporting',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.headingOnDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Complete the sections below to submit a clear complaint. AI will help classify the issue and urgency.',
                      style: TextStyle(color: Color(0xFFE8EEF3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Reporter Details',
                child: Column(
                  children: [
                    TextField(
                      controller: _citizenNameController,
                      decoration: const InputDecoration(
                        labelText: 'Citizen Name',
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedIssue,
                      decoration: const InputDecoration(
                        labelText: 'Issue Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Auto Detect',
                          child: Text('Auto Detect by AI'),
                        ),
                        DropdownMenuItem(
                          value: 'Road Damage',
                          child: Text('Road Damage'),
                        ),
                        DropdownMenuItem(
                          value: 'Water Leakage',
                          child: Text('Water Leakage'),
                        ),
                        DropdownMenuItem(
                          value: 'Street Light',
                          child: Text('Street Light Issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Garbage',
                          child: Text('Garbage Issue'),
                        ),
                        DropdownMenuItem(
                          value: 'Emergency',
                          child: Text('Emergency'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedIssue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'AI Recommended',
                                child: Text('AI Recommended'),
                              ),
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text('High'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedPriority = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image_outlined),
                            label: Text(
                              _photoPath.isEmpty
                                  ? 'Upload Photo'
                                  : 'Photo Added',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_photoPath.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Container(
                                height: 150,
                                width: double.infinity,
                                color: const Color(0xFFF3F8FE),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Image preview is supported on mobile/desktop apps.',
                                  style: TextStyle(color: Color(0xFF4F677A)),
                                ),
                              )
                            : Image.file(
                                File(_photoPath),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: const Color(0xFFF3F8FE),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Unable to load selected image.',
                                      style: TextStyle(
                                        color: Color(0xFF4F677A),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Describe the Issue',
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the issue in detail',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Location & Status',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDDF8)),
                      ),
                      child: Text(
                        'Tagged Location: $_locationText',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_locationText == 'Not Selected') ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Select a location to continue with submission.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationScreen(
                                initialLocationText: _locationText,
                              ),
                            ),
                          );

                          if (result == null) return;
                          setState(() {
                            _locationText = result as String;
                          });
                        },
                        icon: const Icon(Icons.location_on_rounded),
                        label: const Text('Tag Location'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'AI Assistance',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Use AI to classify the issue quickly and assign a department.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _runAiClassification,
                        icon: const Icon(Icons.psychology_alt_rounded),
                        label: const Text('Run AI Classification'),
                      ),
                    ),
                    if (_analysis != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFEAF4FF),
                          border: Border.all(color: const Color(0xFFBFDDF8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category: ${_analysis!.category}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Priority: ${_analysis!.priority}'),
                            Text(
                              'Urgency Score: ${(_analysis!.urgencyScore * 100).toStringAsFixed(0)}%',
                            ),
                            Text('Department: ${_analysis!.department}'),
                            Text('ETA: ${_analysis!.etaHours} hours'),
                            const SizedBox(height: 6),
                            Text(
                              'Signals: ${_analysis!.matchedSignals.isEmpty ? 'No strong keywords' : _analysis!.matchedSignals.join(', ')}',
                              style: const TextStyle(color: Color(0xFF35576F)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canSubmit ? _submitComplaint : null,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
              fontSize: 16,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
