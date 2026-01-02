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
    final techCount = users.where((u) => u.role == UserRole.technician).length;
    final managerCount = users.where((u) => u.role == UserRole.manager).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Admin Dashboard'),
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
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDarkGreen.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${currentUser!.fullName.split(' ').first}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your system overview',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Grid (2x2)
            Text('System Overview', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total Users', '${users.length}',
                          Icons.people, AppColors.info, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                          'Technicians',
                          '$techCount',
                          Icons.engineering,
                          AppColors.primaryDarkGreen,
                          isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Managers', '$managerCount',
                          Icons.supervisor_account, AppColors.warning, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                          'Machines',
                          '${machines.length}',
                          Icons.precision_manufacturing,
                          AppColors.critical,
                          isDark),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text('Quick Actions', style: AppTextStyles.h5),
            const SizedBox(height: 16),
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
                      'System Settings', Icons.settings_suggest, () {}, isDark),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard('Add User', Icons.person_add,
                            () => context.go('/admin/users/add'), isDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard('Manage Users', Icons.people,
                            () => context.go('/admin/users'), isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard('System Settings',
                            Icons.settings_suggest, () {}, isDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 32),

            // Recent Users Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Users', style: AppTextStyles.h5),
                TextButton.icon(
                  onPressed: () => context.go('/admin/users'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDarkGreen.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryDarkGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(UserModel user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.15),
            child: Text(
              user.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              user.role.displayName,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryDarkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
