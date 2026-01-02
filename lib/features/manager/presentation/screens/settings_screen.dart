import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.2),
                  child: Text(currentUser?.fullName.substring(0, 1) ?? 'M', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUser?.fullName ?? 'Manager', style: AppTextStyles.h6),
                    Text(currentUser?.role.displayName ?? '', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Preferences', style: AppTextStyles.labelLarge.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          _buildSettingsTile('Theme', isDark ? 'Dark Mode' : 'Light Mode', Icons.brightness_6, () {
            ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
          }, trailing: Switch(value: isDark, onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light)),
          _buildSettingsTile('Notifications', 'Push notifications enabled', Icons.notifications_outlined, () {}),
          _buildSettingsTile('Language', 'English', Icons.language, () {}),
          const SizedBox(height: 24),

          Text('System', style: AppTextStyles.labelLarge.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          _buildSettingsTile('Alert Thresholds', 'Configure severity levels', Icons.tune, () {}),
          _buildSettingsTile('Cost Settings', 'Set cost per hour values', Icons.attach_money, () {}),
          _buildSettingsTile('AI Sensitivity', 'Adjust AI alert confidence', Icons.psychology, () {}),
          const SizedBox(height: 24),

          Text('Support', style: AppTextStyles.labelLarge.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          _buildSettingsTile('Help & FAQ', '', Icons.help_outline, () {}),
          _buildSettingsTile('Contact Support', '', Icons.support_agent, () {}),
          _buildSettingsTile('About', 'Version 1.0.0', Icons.info_outline, () {}),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () { ref.read(authServiceProvider).signOut(); context.go('/login'); },
            icon: const Icon(Icons.logout, color: AppColors.critical),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.critical)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: AppColors.critical)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDarkGreen),
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: AppTextStyles.bodySmall) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
