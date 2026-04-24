class Complaint {
  final String issueType;
  final String description;
  final String priority;
  final String location;
  final String status;

  Complaint({
    required this.issueType,
    required this.description,
    required this.priority,
    required this.location,
    this.status = "Pending",
  });
}

class ComplaintStore {
  static List<Complaint> complaints = [];
}