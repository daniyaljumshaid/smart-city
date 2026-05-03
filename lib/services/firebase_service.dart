import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../complaint_store.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Unable to create the user account.',
      );
    }

    await user.updateDisplayName(name);
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  static Stream<List<Map<String, dynamic>>> streamUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Future<String> createOfficerProfile({
    required String name,
    required String email,
    required String department,
  }) async {
    final docRef = _firestore.collection('users').doc();
    final data = {
      'uid': docRef.id,
      'name': name,
      'email': email,
      'role': UserRole.officer,
      'department': department,
      'pendingAuth': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await docRef.set(data);
    return docRef.id;
  }

  static Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  static Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? department,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'department': department ?? 'General',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<List<Complaint>> streamComplaints() {
    return _firestore.collection('complaints').snapshots().map((snapshot) {
      final complaints = snapshot.docs
          .map((doc) => complaintFromMap(doc.data()))
          .toList();
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return complaints;
    });
  }

  static Complaint complaintFromMap(Map<String, dynamic> data) {
    final updates = (data['updates'] as List<dynamic>? ?? const [])
        .map(
          (entry) => ComplaintUpdate(
            status: (entry as Map<String, dynamic>)['status'] as String? ??
                'Pending',
            note: entry['note'] as String? ?? '',
            by: entry['by'] as String? ?? 'System',
            createdAt: DateTime.tryParse(entry['createdAt'] as String? ?? '') ??
                DateTime.now(),
            evidencePath: entry['evidencePath'] as String?,
          ),
        )
        .toList();

    return Complaint(
      id: data['id'] as String?,
      issueType: data['issueType'] as String? ?? 'Unknown',
      description: data['description'] as String? ?? '',
      priority: data['priority'] as String? ?? 'Low',
      location: data['location'] as String? ?? 'Unknown',
      status: data['status'] as String? ?? 'Pending',
      citizenName: data['citizenName'] as String? ?? 'Citizen',
      department: data['department'] as String? ?? 'General Civic Services',
      urgencyScore: (data['urgencyScore'] as num?)?.toDouble() ?? 0.0,
      assignedOfficer: data['assignedOfficer'] as String? ?? 'Unassigned',
      imagePath: data['imagePath'] as String?,
      estimatedHours: (data['estimatedHours'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      updates: updates.isEmpty
          ? null
          : updates,
    );
  }

  static Future<String?> uploadComplaintImage({
    required String complaintId,
    required String localImagePath,
  }) async {
    if (localImagePath.trim().isEmpty) return null;

    final file = File(localImagePath);
    if (!await file.exists()) return null;

    final fileName = localImagePath.split(Platform.pathSeparator).last;
    final ref = _storage.ref('complaints/$complaintId/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  static Future<void> saveComplaint({
    required Complaint complaint,
    String? localImagePath,
  }) async {
    final imageUrl = localImagePath == null
        ? null
        : await uploadComplaintImage(
            complaintId: complaint.id,
            localImagePath: localImagePath,
          );

    await _firestore.collection('complaints').doc(complaint.id).set({
      'id': complaint.id,
      'citizenName': complaint.citizenName,
      'issueType': complaint.issueType,
      'description': complaint.description,
      'priority': complaint.priority,
      'location': complaint.location,
      'status': complaint.status,
      'department': complaint.department,
      'urgencyScore': complaint.urgencyScore,
      'estimatedHours': complaint.estimatedHours,
      'assignedOfficer': complaint.assignedOfficer,
      'imagePath': complaint.imagePath,
      'imageUrl': imageUrl,
      'createdAt': complaint.createdAt.toIso8601String(),
      'updatedAt': complaint.updatedAt.toIso8601String(),
      'updates': complaint.updates
          .map(
            (update) => {
              'status': update.status,
              'note': update.note,
              'by': update.by,
              'createdAt': update.createdAt.toIso8601String(),
              'evidencePath': update.evidencePath,
            },
          )
          .toList(),
            }, SetOptions(merge: true));
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}