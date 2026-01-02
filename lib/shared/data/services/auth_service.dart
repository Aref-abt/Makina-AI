import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
export '../models/models.dart';
import 'mock_data_service.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user provider
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MockDataService _mockData = MockDataService();

  AuthService(this._ref);

  User? get currentFirebaseUser => _auth.currentUser;

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Try Firebase auth first
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Map to our user model from mock data
        final userModel = _getUserModelByEmail(email);
        if (userModel != null) {
          _ref.read(currentUserProvider.notifier).state = userModel;
          return AuthResult.success(userModel);
        }
      }

      return AuthResult.error('User not found in system');
    } on FirebaseAuthException {
      // For prototype, allow mock login if Firebase fails
      return _tryMockLogin(email, password);
    } catch (e) {
      // For prototype, allow mock login
      return _tryMockLogin(email, password);
    }
  }

  // Mock login for prototype (when Firebase is not available)
  AuthResult _tryMockLogin(String email, String password) {
    // Mock credentials for prototype
    final mockCredentials = {
      'admin@makina.ai': 'Admin123!',
      'manager@makina.ai': 'Manager123!',
      'tech@makina.ai': 'Tech123!',
    };

    if (mockCredentials[email] == password) {
      final userModel = _getUserModelByEmail(email);
      if (userModel != null) {
        _ref.read(currentUserProvider.notifier).state = userModel;
        return AuthResult.success(userModel);
      }
    }

    return AuthResult.error('Invalid email or password');
  }

  // Get user model by email from mock data
  UserModel? _getUserModelByEmail(String email) {
    try {
      return _mockData.users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Ignore Firebase sign out errors for prototype
    }
    _ref.read(currentUserProvider.notifier).state = null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _ref.read(currentUserProvider) != null;

  // Get current user model
  UserModel? get currentUser => _ref.read(currentUserProvider);

  // Create user (for super admin)
  Future<AuthResult> createUser({
    required String email,
    required String password,
    required String fullName,
    required String employeeId,
    required UserRole role,
    String? assignedFloor,
    List<ExpertiseType> expertise = const [],
    List<String> assignedMachineIds = const [],
  }) async {
    try {
      // In production, would create Firebase user and Firestore document
      // For prototype, just add to mock data
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        employeeId: employeeId,
        email: email,
        role: role,
        assignedFloor: assignedFloor,
        expertise: expertise,
        assignedMachineIds: assignedMachineIds,
      );

      _mockData.users.add(newUser);
      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.error('Failed to create user: $e');
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
