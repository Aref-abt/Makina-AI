import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentUser = ref.watch(currentUserProvider);
        final themeNotifier = ref.read(themeModeProvider.notifier);

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppColors.primaryDarkGreen.withOpacity(0.2),
                        child: Text(
                          currentUser?.fullName.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkGreen),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(currentUser?.fullName ?? 'User',
                          style: AppTextStyles.h4),
                      const SizedBox(height: 4),
                      Text(currentUser?.email ?? '',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.primaryDarkGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(currentUser?.role.displayName ?? '',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primaryDarkGreen)),
                      ),
                      const SizedBox(height: 16),
                      if (currentUser?.expertise.isNotEmpty ?? false) ...[
                        Text('Expertise',
                            style: AppTextStyles.labelMedium
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: currentUser!.expertise
                              .map((e) => Chip(
                                    label: Text(e.displayName,
                                        style: AppTextStyles.labelSmall),
                                    backgroundColor: AppColors.primaryDarkGreen
                                        .withOpacity(0.15),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings Section
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Text('Settings', style: AppTextStyles.h6),
                      ),
                      const Divider(height: 1),
                      // Theme Toggle
                      ListTile(
                        leading: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: AppColors.primaryDarkGreen),
                        title: const Text('Theme'),
                        subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode'),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (value) {
                            themeNotifier.state =
                                value ? ThemeMode.dark : ThemeMode.light;
                          },
                          activeColor: AppColors.primaryDarkGreen,
                        ),
                      ),
                      const Divider(height: 1),
                      // Notifications
                      ListTile(
                        leading: Icon(Icons.notifications_outlined,
                            color: AppColors.primaryDarkGreen),
                        title: const Text('Notifications'),
                        subtitle: Text(
                            _notificationsEnabled ? 'Enabled' : 'Disabled'),
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) =>
                              setState(() => _notificationsEnabled = value),
                          activeColor: AppColors.primaryDarkGreen,
                        ),
                      ),
                      const Divider(height: 1),
                      // Language
                      ListTile(
                        leading: Icon(Icons.language,
                            color: AppColors.primaryDarkGreen),
                        title: const Text('Language'),
                        subtitle: Text(_language),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Language selection dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Language'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  'English',
                                  'Spanish',
                                  'French',
                                  'German'
                                ]
                                    .map((lang) => ListTile(
                                          title: Text(lang),
                                          selected: _language == lang,
                                          onTap: () {
                                            setState(() => _language = lang);
                                            Navigator.pop(context);
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      // Help & Support
                      ListTile(
                        leading: Icon(Icons.help_outline,
                            color: AppColors.primaryDarkGreen),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Help & Support feature coming soon')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      // About
                      ListTile(
                        leading: Icon(Icons.info_outline,
                            color: AppColors.primaryDarkGreen),
                        title: const Text('About'),
                        subtitle: const Text('v1.0.0'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Makina AI',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                '© 2024 Makina AI. All rights reserved.',
                            children: [
                              const Text(
                                  'Predictive Maintenance Platform for Industrial Equipment'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.critical),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppColors.critical)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.critical),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
