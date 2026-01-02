import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/auth_service.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mockData = MockDataService();
    final kpis = mockData.getDashboardKPIs();
    final currentUser = ref.watch(currentUserProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
                'Welcome, ${currentUser?.fullName.split(' ').first ?? 'Manager'}',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            GridView.count(
              crossAxisCount: isTablet ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isTablet ? 1.5 : 1.3,
              children: [
                _buildKPICard(
                    'Total Machines',
                    '${kpis.totalMachines}',
                    Icons.precision_manufacturing,
                    AppColors.primaryDarkGreen,
                    isDark),
                _buildKPICard('Active Tickets', '${kpis.activeTickets}',
                    Icons.assignment, AppColors.info, isDark),
                _buildKPICard('Critical', '${kpis.criticalTickets}',
                    Icons.warning_amber, AppColors.critical, isDark),
                _buildKPICard(
                    'Downtime',
                    '${kpis.totalDowntimeHours.toStringAsFixed(1)}h',
                    Icons.timer_off,
                    AppColors.warning,
                    isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Machine Health Overview
            Text('Machine Health Overview', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: _buildHealthBar('Healthy', kpis.healthyMachines,
                          kpis.totalMachines, AppColors.healthy, isDark)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildHealthBar('Warning', kpis.warningMachines,
                          kpis.totalMachines, AppColors.warning, isDark)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildHealthBar('Critical', kpis.criticalMachines,
                          kpis.totalMachines, AppColors.critical, isDark)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cost Impact
            Text('Cost Impact', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.critical.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05)
                ]),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(color: AppColors.critical.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.critical.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.attach_money,
                        color: AppColors.critical, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Cost Impact',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                      const SizedBox(height: 4),
                      Text('\$${kpis.estimatedCostImpact.toStringAsFixed(0)}',
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.critical)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                              kpis.downtimeChangePercent < 0
                                  ? Icons.trending_down
                                  : Icons.trending_up,
                              color: kpis.downtimeChangePercent < 0
                                  ? AppColors.healthy
                                  : AppColors.critical,
                              size: 16),
                          const SizedBox(width: 4),
                          Text(
                              '${kpis.downtimeChangePercent.abs().toStringAsFixed(1)}%',
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: kpis.downtimeChangePercent < 0
                                      ? AppColors.healthy
                                      : AppColors.critical)),
                        ],
                      ),
                      Text('vs last week',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Response Metrics
            Text('Response Metrics', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildMetricCard(
                        'Avg Response Time',
                        '${kpis.avgResponseTimeMinutes.toStringAsFixed(0)} min',
                        Icons.speed,
                        AppColors.info,
                        isDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildMetricCard(
                        'Avg Resolution Time',
                        '${kpis.avgResolutionTimeMinutes.toStringAsFixed(0)} min',
                        Icons.check_circle_outline,
                        AppColors.healthy,
                        isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value,
              style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 2),
          Text(title,
              style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildHealthBar(
      String label, int count, int total, Color color, bool isDark) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    return Column(
      children: [
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
        const SizedBox(height: 8),
        Text('$count', style: AppTextStyles.h5.copyWith(color: color)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color)),
        ),
        const SizedBox(height: 4),
        Text('${percentage.toStringAsFixed(0)}%',
            style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.h6.copyWith(
                      color:
                          isDark ? AppColors.darkText : AppColors.lightText)),
              Text(title,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
