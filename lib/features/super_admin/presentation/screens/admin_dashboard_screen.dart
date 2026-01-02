import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/auth_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < AppDimensions.mobileBreakpoint;
    final mockData = MockDataService();
    final users = mockData.users;
    final machines = mockData.machines;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard'),
            Text('Welcome, ${currentUser?.fullName ?? 'Admin'}',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authServiceProvider).signOut();
                context.go('/login');
              }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards - Responsive Grid
            if (isMobile)
              Column(
                children: [
                  _buildStatCard('Total Users', '${users.length}', Icons.people,
                      AppColors.info, isDark),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      'Technicians',
                      '${users.where((u) => u.role == UserRole.technician).length}',
                      Icons.engineering,
                      AppColors.primaryDarkGreen,
                      isDark),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      'Managers',
                      '${users.where((u) => u.role == UserRole.manager).length}',
                      Icons.supervisor_account,
                      AppColors.warning,
                      isDark),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      'Machines',
                      '${machines.length}',
                      Icons.precision_manufacturing,
                      AppColors.critical,
                      isDark),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard('Total Users', '${users.length}',
                          Icons.people, AppColors.info, isDark)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Technicians',
                          '${users.where((u) => u.role == UserRole.technician).length}',
                          Icons.engineering,
                          AppColors.primaryDarkGreen,
                          isDark)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Managers',
                          '${users.where((u) => u.role == UserRole.manager).length}',
                          Icons.supervisor_account,
                          AppColors.warning,
                          isDark)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Machines',
                          '${machines.length}',
                          Icons.precision_manufacturing,
                          AppColors.critical,
                          isDark)),
                ],
              ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            if (isMobile)
              Column(
                children: [
                  _buildActionCard('Add User', Icons.person_add,
                      () => context.go('/admin/users/add'), isDark),
                  const SizedBox(height: 12),
                  _buildActionCard('Manage Users', Icons.people,
                      () => context.go('/admin/users'), isDark),
                  const SizedBox(height: 12),
                  _buildActionCard(
                      'System Settings', Icons.settings, () {}, isDark),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                      child: _buildActionCard('Add User', Icons.person_add,
                          () => context.go('/admin/users/add'), isDark)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildActionCard('Manage Users', Icons.people,
                          () => context.go('/admin/users'), isDark)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildActionCard(
                          'System Settings', Icons.settings, () {}, isDark)),
                ],
              ),
            const SizedBox(height: 24),

            // Recent Users
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Users', style: AppTextStyles.h6),
                TextButton(
                    onPressed: () => context.go('/admin/users'),
                    child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            ...users.take(5).map((user) => _buildUserTile(user, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h4),
          Text(title,
              style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primaryDarkGreen, size: 32),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.labelMedium)
        ]),
      ),
    );
  }

  Widget _buildUserTile(UserModel user, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.2),
            child: Text(user.fullName.substring(0, 1),
                style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.bold))),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
          child: Text(user.role.displayName,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primaryDarkGreen)),
        ),
      ),
    );
  }
}
