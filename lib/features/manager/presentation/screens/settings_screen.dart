import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/services/auth_service.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/models/models.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.2),
                  child: Text(currentUser?.fullName.substring(0, 1) ?? 'M',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkGreen)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUser?.fullName ?? 'Manager',
                        style: AppTextStyles.h6),
                    Text(currentUser?.role.displayName ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Preferences',
              style: AppTextStyles.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          _buildSettingsTile(
              'Theme', isDark ? 'Dark Mode' : 'Light Mode', Icons.brightness_6,
              () {
            ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
              trailing: Switch(
                  value: isDark,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).state =
                      v ? ThemeMode.dark : ThemeMode.light)),
          _buildSettingsTile('Notifications', 'Push notifications enabled',
              Icons.notifications_outlined, () {}),
          _buildSettingsTile('Language', 'English', Icons.language, () {}),
          const SizedBox(height: 24),

          Text('System',
              style: AppTextStyles.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Builder(builder: (ctx) {
            final service = MockDataService();
            return Column(children: [
              _buildSettingsTile(
                  'Alert Thresholds',
                  '${service.alertThresholds.length} sensors configured',
                  Icons.tune,
                  () => _openAlertThresholds(context)),
              _buildSettingsTile(
                  'Cost Settings',
                  'Default: \$${service.defaultCostPerHour.toStringAsFixed(0)}',
                  Icons.attach_money,
                  () => _openCostSettings(context)),
              _buildSettingsTile(
                  'AI Sensitivity',
                  '${(service.aiSensitivityThreshold * 100).toStringAsFixed(0)}% confidence threshold',
                  Icons.psychology,
                  () => _openAiSensitivity(context)),
            ]);
          }),
          const SizedBox(height: 24),

          Text('Support',
              style: AppTextStyles.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          _buildSettingsTile('Help & FAQ', '', Icons.help_outline, () {}),
          _buildSettingsTile('Contact Support', '', Icons.support_agent, () {}),
          _buildSettingsTile(
              'About', 'Version 1.0.0', Icons.info_outline, () {}),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
            icon: const Icon(Icons.logout, color: AppColors.critical),
            label: const Text('Sign Out',
                style: TextStyle(color: AppColors.critical)),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.critical)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDarkGreen),
        title: Text(title),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: AppTextStyles.bodySmall)
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _openAlertThresholds(BuildContext context) {
    final service = MockDataService();
    final thresholds = service.alertThresholds;
    final entries = thresholds.entries.toList();
    final controllers = <String, Map<String, TextEditingController>>{};
    for (final e in entries) {
      controllers[e.key] = {
        'min': TextEditingController(text: e.value.min.toStringAsFixed(1)),
        'max': TextEditingController(text: e.value.max.toStringAsFixed(1)),
      };
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Alert Thresholds'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: entries.map((e) {
                      final key = e.key;
                      final range = e.value;
                      final minCtrl = controllers[key]!['min']!;
                      final maxCtrl = controllers[key]!['max']!;
                      final label = key.isNotEmpty
                          ? (key[0].toUpperCase() + key.substring(1))
                          : key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(label,
                                    style: AppTextStyles.bodyMedium)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: minCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Min',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    if (double.tryParse(v) == null)
                                      return 'Invalid';
                                    return null;
                                  },
                                )),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: maxCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Max',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    if (double.tryParse(v) == null)
                                      return 'Invalid';
                                    return null;
                                  },
                                )),
                            const SizedBox(width: 8),
                            SizedBox(
                                width: 60,
                                child: Text(range.unit,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySmall)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    for (final e in entries) {
                      final key = e.key;
                      final minText = controllers[key]!['min']!.text;
                      final maxText = controllers[key]!['max']!.text;
                      final minV = double.tryParse(minText) ?? e.value.min;
                      final maxV = double.tryParse(maxText) ?? e.value.max;
                      service.setAlertThreshold(key,
                          ASMERange(min: minV, max: maxV, unit: e.value.unit));
                    }
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thresholds saved')));
                  },
                  child: const Text('Save')),
            ],
          );
        });
  }

  void _openCostSettings(BuildContext context) {
    final service = MockDataService();
    final ctrl = TextEditingController(
        text: service.defaultCostPerHour.toStringAsFixed(0));
    var applyToMachines = false;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Cost Settings'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Default cost per hour (USD)')),
              const SizedBox(height: 12),
              StatefulBuilder(builder: (c, setState) {
                return CheckboxListTile(
                    title: const Text('Apply to all machines'),
                    value: applyToMachines,
                    onChanged: (v) =>
                        setState(() => applyToMachines = v ?? false));
              })
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    final v = double.tryParse(ctrl.text) ??
                        service.defaultCostPerHour;
                    service.setDefaultCostPerHour(v,
                        applyToMachines: applyToMachines);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cost settings saved')));
                  },
                  child: const Text('Save')),
            ],
          );
        });
  }

  void _openAiSensitivity(BuildContext context) {
    final service = MockDataService();
    double value = service.aiSensitivityThreshold;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('AI Sensitivity'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Only show AI alerts with confidence above the threshold.'),
              const SizedBox(height: 12),
              StatefulBuilder(builder: (c, setState) {
                return Column(children: [
                  Slider(
                      value: value,
                      onChanged: (v) => setState(() => value = v),
                      min: 0.0,
                      max: 1.0),
                  Text('${(value * 100).toStringAsFixed(0)}% confidence')
                ]);
              })
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    MockDataService().setAiSensitivityThreshold(value);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('AI sensitivity updated')));
                  },
                  child: const Text('Save')),
            ],
          );
        });
  }
}
