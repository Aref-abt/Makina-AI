import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== USER OPERATIONS ==========

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'fullName': user.fullName,
        'employeeId': user.employeeId,
        'email': user.email,
        'role': user.role.name,
        'assignedFloor': user.assignedFloor,
        'expertise': user.expertise.map((e) => e.name).toList(),
        'assignedMachineIds': user.assignedMachineIds,
        'isActive': user.isActive,
        'createdAt': user.createdAt,
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'fullName': user.fullName,
        'employeeId': user.employeeId,
        'email': user.email,
        'role': user.role.name,
        'assignedFloor': user.assignedFloor,
        'expertise': user.expertise.map((e) => e.name).toList(),
        'assignedMachineIds': user.assignedMachineIds,
        'isActive': user.isActive,
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => _parseUserModel(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  UserModel _parseUserModel(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      fullName: data['fullName'] ?? '',
      employeeId: data['employeeId'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.technician,
      ),
      assignedFloor: data['assignedFloor'],
      expertise: (data['expertise'] as List?)
              ?.map((e) => ExpertiseType.values.firstWhere(
                    (ex) => ex.name == e,
                    orElse: () => ExpertiseType.general,
                  ))
              .toList() ??
          [],
      assignedMachineIds: List<String>.from(data['assignedMachineIds'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ========== TICKET OPERATIONS ==========

  Future<void> addTicket(TicketModel ticket) async {
    try {
      await _firestore.collection('tickets').doc(ticket.id).set({
        'id': ticket.id,
        'title': ticket.title,
        'description': ticket.description,
        'status': ticket.status.name,
        'severity': ticket.severity.name,
        'machineId': ticket.machineId,
        'machineName': ticket.machineName,
        'createdAt': ticket.createdAt,
        'resolvedAt': ticket.resolvedAt,
      });
    } catch (e) {
      throw Exception('Failed to add ticket: $e');
    }
  }

  Future<void> updateTicket(TicketModel ticket) async {
    try {
      await _firestore.collection('tickets').doc(ticket.id).update({
        'title': ticket.title,
        'description': ticket.description,
        'status': ticket.status.name,
        'severity': ticket.severity.name,
        'machineId': ticket.machineId,
        'machineName': ticket.machineName,
        'resolvedAt': ticket.resolvedAt,
      });
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  // ========== FEEDBACK OPERATIONS ==========

  Future<void> submitFeedback(TechnicianFeedback feedback) async {
    try {
      await _firestore.collection('feedback').doc(feedback.id).set({
        'id': feedback.id,
        'ticketId': feedback.ticketId,
        'technicianId': feedback.technicianId,
        'noiseLevel': feedback.noiseLevel.name,
        'vibrationFelt': feedback.vibrationFelt,
        'heatFelt': feedback.heatFelt,
        'visibleLeak': feedback.visibleLeak,
        'smellDetected': feedback.smellDetected,
        'actionTaken': feedback.actionTaken.name,
        'outcome': feedback.outcome.name,
        'verification': feedback.verification.name,
        'notes': feedback.notes,
        'submittedAt': feedback.submittedAt,
      });
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<TechnicianFeedback?> getFeedback(String feedbackId) async {
    try {
      final doc = await _firestore.collection('feedback').doc(feedbackId).get();
      if (doc.exists) {
        return _parseFeedback(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get feedback: $e');
    }
  }

  TechnicianFeedback _parseFeedback(Map<String, dynamic> data) {
    return TechnicianFeedback(
      id: data['id'] ?? '',
      ticketId: data['ticketId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      noiseLevel: NoiseLevel.values.firstWhere(
        (n) => n.name == data['noiseLevel'],
        orElse: () => NoiseLevel.none,
      ),
      vibrationFelt: data['vibrationFelt'] ?? false,
      heatFelt: data['heatFelt'] ?? false,
      visibleLeak: data['visibleLeak'] ?? false,
      smellDetected: data['smellDetected'] ?? false,
      actionTaken: ActionTaken.values.firstWhere(
        (a) => a.name == data['actionTaken'],
        orElse: () => ActionTaken.inspection,
      ),
      outcome: Outcome.values.firstWhere(
        (o) => o.name == data['outcome'],
        orElse: () => Outcome.resolved,
      ),
      verification: data['verification'] != null
          ? IssueVerification.values.firstWhere(
              (i) => i.name == data['verification'],
              orElse: () => IssueVerification.issueFound,
            )
          : IssueVerification.issueFound,
      notes: data['notes'],
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ========== REPORT OPERATIONS ==========

  Future<void> saveReport(Map<String, dynamic> reportData) async {
    try {
      final reportId =
          reportData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('reports').doc(reportId).set({
        ...reportData,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  Future<bool> userExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> initializeSampleData() async {
    try {
      // Check if sample data already exists
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      if (usersSnapshot.docs.isNotEmpty) {
        return; // Data already initialized
      }

      // Add sample users
      final sampleUsers = [
        UserModel(
          id: 'user_001',
          fullName: 'John Smith',
          employeeId: 'EMP001',
          email: 'tech@makina.ai',
          role: UserRole.technician,
          assignedFloor: 'Floor 1',
          expertise: [ExpertiseType.mechanical, ExpertiseType.electrical],
          assignedMachineIds: ['machine_001', 'machine_002'],
        ),
        UserModel(
          id: 'user_002',
          fullName: 'Sarah Johnson',
          employeeId: 'EMP002',
          email: 'manager@makina.ai',
          role: UserRole.manager,
          assignedFloor: 'Floor 1',
          expertise: [],
          assignedMachineIds: ['machine_001', 'machine_002', 'machine_003'],
        ),
        UserModel(
          id: 'user_003',
          fullName: 'Admin User',
          employeeId: 'EMP003',
          email: 'admin@makina.ai',
          role: UserRole.superAdmin,
          expertise: [],
          assignedMachineIds: [],
        ),
      ];

      for (final user in sampleUsers) {
        await addUser(user);
      }
    } catch (e) {
      // Silently fail on initialization - might already exist
      print('Failed to initialize sample data: $e');
    }
  }
}
