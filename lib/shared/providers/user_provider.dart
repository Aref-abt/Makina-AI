import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/mock_data_service.dart';

// Provider for users list that can be watched and updated
final usersProvider = StateProvider<List<UserModel>>((ref) {
  return MockDataService().users;
});

// Provider to refresh/refetch users
final refreshUsersProvider = Provider<void>((ref) {
  final mockData = MockDataService();
  ref.read(usersProvider.notifier).state = List.from(mockData.users);
});
