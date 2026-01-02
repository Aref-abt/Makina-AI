import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = MockDataService().users;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add User'), onPressed: () => context.go('/admin/users/add')),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: _getRoleColor(user.role).withOpacity(0.2), child: Text(user.fullName.substring(0, 1), style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.bold))),
              title: Text(user.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: user.expertise.take(3).map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                      child: Text(e.displayName, style: AppTextStyles.labelSmall),
                    )).toList(),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _getRoleColor(user.role).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(user.role.displayName, style: AppTextStyles.labelSmall.copyWith(color: _getRoleColor(user.role))),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/admin/users/edit/${user.id}')),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return AppColors.critical;
      case UserRole.manager: return AppColors.warning;
      case UserRole.technician: return AppColors.primaryDarkGreen;
    }
  }
}
