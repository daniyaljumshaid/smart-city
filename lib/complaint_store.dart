class UserRole {
  static const String citizen = 'Citizen';
  static const String officer = 'Government Officer';
  static const String admin = 'Admin';
}

class ComplaintUpdate {
  final String status;
  final String note;
  final String by;
  final DateTime createdAt;
  final String? evidencePath;

  ComplaintUpdate({
    required this.status,
    required this.note,
    required this.by,
    DateTime? createdAt,
    this.evidencePath,
  }) : createdAt = createdAt ?? DateTime.now();
}

class Complaint {
  final String id;
  String issueType;
  final String description;
  String priority;
  String location;
  String status;
  final String citizenName;
  String department;
  double urgencyScore;
  int estimatedHours;
  String assignedOfficer;
  final String? imagePath;
  DateTime createdAt;
  DateTime updatedAt;
  final List<ComplaintUpdate> updates;

  Complaint({
    String? id,
    required this.issueType,
    required this.description,
    required this.priority,
    required this.location,
    this.status = 'Pending',
    this.citizenName = 'Citizen',
    this.department = 'General Civic Services',
    this.urgencyScore = 0.40,
    this.assignedOfficer = 'Unassigned',
    this.imagePath,
    int? estimatedHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ComplaintUpdate>? updates,
  }) : id = id ?? _buildId(),
       estimatedHours = estimatedHours ?? _defaultEta(priority),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       updates =
           updates ??
           [
             ComplaintUpdate(
               status: status,
               note: 'Complaint created by citizen.',
               by: 'Citizen',
             ),
           ];

  static String _buildId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'CMP-$now';
  }

  static int _defaultEta(String priority) {
    if (priority == 'High') return 12;
    if (priority == 'Medium') return 30;
    return 72;
  }
}

class CitizenNotification {
  final String id;
  final String message;
  final String targetRole;
  final DateTime createdAt;
  bool isRead;

  CitizenNotification({
    required this.id,
    required this.message,
    required this.targetRole,
    required this.createdAt,
    this.isRead = false,
  });
}

class CommunityPoll {
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;

  CommunityPoll({
    required this.id,
    required this.question,
    required this.options,
    List<int>? votes,
  }) : votes = votes ?? List<int>.filled(options.length, 0);

  int get totalVotes => votes.fold(0, (a, b) => a + b);
}

class CommunitySuggestion {
  final String author;
  final String message;
  final DateTime createdAt;

  CommunitySuggestion({
    required this.author,
    required this.message,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class CityAnnouncement {
  final String title;
  final String details;
  final DateTime createdAt;

  CityAnnouncement({
    required this.title,
    required this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ComplaintStore {
  static final List<Complaint> complaints = [
    Complaint(
      id: 'CMP-2401',
      citizenName: 'Ayesha Khan',
      issueType: 'Road Damage',
      description: 'Deep pothole near Main Street flyover causing accidents.',
      priority: 'High',
      location: 'Main Street, Downtown',
      status: 'In Progress',
      department: 'Roads & Transport',
      urgencyScore: 0.88,
      assignedOfficer: 'Officer Tariq',
      estimatedHours: 14,
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      updates: [
        ComplaintUpdate(
          status: 'In Progress',
          note: 'Repair team dispatched and barricades installed.',
          by: 'Officer Tariq',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ComplaintUpdate(
          status: 'Assigned',
          note: 'Task assigned to Roads & Transport department.',
          by: 'System AI',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
    Complaint(
      id: 'CMP-2402',
      citizenName: 'Raza Malik',
      issueType: 'Garbage',
      description: 'Garbage accumulation near public school gate.',
      priority: 'Medium',
      location: 'Sector 12, North Block',
      status: 'Assigned',
      department: 'Waste Management',
      urgencyScore: 0.63,
      assignedOfficer: 'Officer Sana',
      estimatedHours: 20,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      updates: [
        ComplaintUpdate(
          status: 'Assigned',
          note: 'Waste management team scheduled for evening shift.',
          by: 'Officer Sana',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    Complaint(
      id: 'CMP-2403',
      citizenName: 'Hina Iqbal',
      issueType: 'Water Leakage',
      description: 'Pipeline leak flooding service lane for two days.',
      priority: 'High',
      location: 'Central Park Avenue',
      status: 'Pending',
      department: 'Water & Sanitation',
      urgencyScore: 0.79,
      assignedOfficer: 'Officer Bilal',
      estimatedHours: 16,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<CitizenNotification> notifications = [
    CitizenNotification(
      id: 'NTF-1',
      message: 'Complaint CMP-2401 moved to In Progress.',
      targetRole: UserRole.citizen,
      createdAt: DateTime.now().subtract(const Duration(minutes: 90)),
    ),
    CitizenNotification(
      id: 'NTF-2',
      message: 'Rain alert issued: avoid low-lying roads after 8 PM.',
      targetRole: UserRole.citizen,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  static final List<CommunityPoll> polls = [
    CommunityPoll(
      id: 'POL-1',
      question: 'Which issue should city focus on this week?',
      options: const [
        'Road damage',
        'Garbage disposal',
        'Street lights',
        'Water leakage',
      ],
      votes: [34, 28, 11, 22],
    ),
    CommunityPoll(
      id: 'POL-2',
      question: 'Preferred channel for emergency alerts?',
      options: const ['Mobile App', 'SMS', 'WhatsApp', 'Email'],
      votes: [41, 21, 32, 9],
    ),
  ];

  static final List<CommunitySuggestion> suggestions = [
    CommunitySuggestion(
      author: 'Nadia',
      message: 'Install smart bins near the university gate.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<CityAnnouncement> announcements = [
    CityAnnouncement(
      title: 'Night Road Maintenance Drive',
      details: 'Road patching starts at 11 PM in Downtown and Central Park.',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    CityAnnouncement(
      title: 'Community Clean-Up Weekend',
      details: 'Join local teams this Sunday for neighborhood clean-up.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  static Complaint? findComplaintById(String complaintId) {
    for (final complaint in complaints) {
      if (complaint.id == complaintId) return complaint;
    }
    return null;
  }

  static void addComplaint(Complaint complaint) {
    complaints.insert(0, complaint);
    pushNotification(
      message:
          'Complaint ${complaint.id} submitted and routed to ${complaint.department}.',
      targetRole: UserRole.citizen,
    );
    pushNotification(
      message: 'New task ${complaint.id} assigned to ${complaint.department}.',
      targetRole: UserRole.officer,
    );
  }

  static void addComplaintUpdate({
    required String complaintId,
    required String status,
    required String note,
    required String by,
    String? evidencePath,
    int? etaHours,
    String? assignedOfficer,
  }) {
    final complaint = findComplaintById(complaintId);
    if (complaint == null) return;

    complaint.status = status;
    if (assignedOfficer != null && assignedOfficer.trim().isNotEmpty) {
      complaint.assignedOfficer = assignedOfficer.trim();
    }

    if (etaHours != null) {
      complaint.estimatedHours = etaHours;
    }

    if (status == 'Resolved') {
      complaint.estimatedHours = 0;
    }

    final update = ComplaintUpdate(
      status: status,
      note: note,
      by: by,
      evidencePath: evidencePath,
    );

    complaint.updates.insert(0, update);
    complaint.updatedAt = update.createdAt;

    pushNotification(
      message: 'Complaint $complaintId updated to $status.',
      targetRole: UserRole.citizen,
    );
  }

  static List<Complaint> openComplaints() {
    return complaints.where((c) => c.status != 'Resolved').toList();
  }

  static List<Complaint> complaintsForOfficer() {
    final list = openComplaints();
    list.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return list;
  }

  static Map<String, int> issueTypeCounts() {
    final map = <String, int>{};
    for (final complaint in complaints) {
      map[complaint.issueType] = (map[complaint.issueType] ?? 0) + 1;
    }
    return map;
  }

  static Map<String, int> departmentCounts() {
    final map = <String, int>{};
    for (final complaint in complaints) {
      map[complaint.department] = (map[complaint.department] ?? 0) + 1;
    }
    return map;
  }

  static Map<String, int> areaHotspots() {
    final map = <String, int>{};
    for (final complaint in complaints) {
      final area = _extractArea(complaint.location);
      map[area] = (map[area] ?? 0) + 1;
    }
    return map;
  }

  static String _extractArea(String location) {
    final parts = location.split(',');
    if (parts.isEmpty) return location.trim();
    return parts.first.trim();
  }

  static void pushNotification({
    required String message,
    String targetRole = UserRole.citizen,
  }) {
    notifications.insert(
      0,
      CitizenNotification(
        id: 'NTF-${DateTime.now().millisecondsSinceEpoch}',
        message: message,
        targetRole: targetRole,
        createdAt: DateTime.now(),
      ),
    );
  }

  static void markNotificationRead(String id) {
    for (final notification in notifications) {
      if (notification.id == id) {
        notification.isRead = true;
        return;
      }
    }
  }

  static void markAllNotificationsRead() {
    for (final notification in notifications) {
      notification.isRead = true;
    }
  }

  static void votePoll(String pollId, int optionIndex) {
    for (final poll in polls) {
      if (poll.id != pollId) continue;
      if (optionIndex < 0 || optionIndex >= poll.votes.length) return;
      poll.votes[optionIndex] += 1;
      return;
    }
  }

  static void addSuggestion({required String author, required String message}) {
    suggestions.insert(
      0,
      CommunitySuggestion(author: author, message: message),
    );
  }

  static void addAnnouncement({
    required String title,
    required String details,
  }) {
    announcements.insert(0, CityAnnouncement(title: title, details: details));
  }
}
