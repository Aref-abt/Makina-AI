import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class FactoryMapScreen extends ConsumerWidget {
  const FactoryMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mockData = MockDataService();
    final machines = mockData.machines;
    final users = mockData.users;

    // Group machines by floor (simplified: assume floors 1-2, or extract from location)
    final Map<String, List<MachineModel>> machinesByFloor = {};
    for (var machine in machines) {
      final floor = machine.floor;
      if (!machinesByFloor.containsKey(floor)) {
        machinesByFloor[floor] = [];
      }
      machinesByFloor[floor]!.add(machine);
    }

    // Count staff by floor
    final Map<String, Map<String, int>> staffByFloor = {};
    for (var floor in machinesByFloor.keys) {
      staffByFloor[floor] = {
        'technicians': 0,
        'managers': 0,
      };
    }

    // Assign users to floors (simplified: cycle through floors)
    final floorList = machinesByFloor.keys.toList();
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final floor = floorList[i % floorList.length];
      if (user.role == UserRole.technician) {
        staffByFloor[floor]!['technicians'] =
            staffByFloor[floor]!['technicians']! + 1;
      } else if (user.role == UserRole.manager) {
        staffByFloor[floor]!['managers'] =
            staffByFloor[floor]!['managers']! + 1;
      }
    }

    final sortedFloors = machinesByFloor.keys.toList()..sort();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Factory Map'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDarkGreen.withOpacity(0.1),
                    AppColors.info.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on,
                        color: AppColors.info, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factory Overview',
                          style: AppTextStyles.h5,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sortedFloors.length} Floors • ${machines.length} Machines • ${users.length} Staff',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Floors Grid
            Text('Facility Floors', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            ...List.generate(sortedFloors.length, (index) {
              final floor = sortedFloors[index];
              final floorMachines = machinesByFloor[floor]!;
              final floorStaff = staffByFloor[floor]!;
              final techCount = floorStaff['technicians'] ?? 0;
              final managerCount = floorStaff['managers'] ?? 0;

              // Health status colors for machines
              final criticalCount = floorMachines
                  .where((m) => m.healthStatus == HealthStatus.critical)
                  .length;
              final warningCount = floorMachines
                  .where((m) => m.healthStatus == HealthStatus.warning)
                  .length;
              final healthyCount = floorMachines
                  .where((m) => m.healthStatus == HealthStatus.healthy)
                  .length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildFloorCard(
                  floor: floor,
                  machineCount: floorMachines.length,
                  healthyMachines: healthyCount,
                  warningMachines: warningCount,
                  criticalMachines: criticalCount,
                  technicians: techCount,
                  managers: managerCount,
                  isDark: isDark,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorCard({
    required String floor,
    required int machineCount,
    required int healthyMachines,
    required int warningMachines,
    required int criticalMachines,
    required int technicians,
    required int managers,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
        children: [
          // Floor Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.domain,
                      color: AppColors.primaryDarkGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        floor,
                        style: AppTextStyles.h6.copyWith(
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$machineCount machines',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Machine Health Summary Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthyMachines == machineCount
                        ? AppColors.healthy.withOpacity(0.15)
                        : criticalMachines > 0
                            ? AppColors.critical.withOpacity(0.15)
                            : AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    healthyMachines == machineCount
                        ? 'All Healthy'
                        : criticalMachines > 0
                            ? '⚠️ Critical'
                            : '⚡ Warning',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: healthyMachines == machineCount
                          ? AppColors.healthy
                          : criticalMachines > 0
                              ? AppColors.critical
                              : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Machines Status Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Healthy',
                        '$healthyMachines',
                        Icons.check_circle,
                        AppColors.healthy,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Warning',
                        '$warningMachines',
                        Icons.warning,
                        AppColors.warning,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Critical',
                        '$criticalMachines',
                        Icons.error,
                        AppColors.critical,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                const SizedBox(height: 16),

                // Staff Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Technicians',
                        '$technicians',
                        Icons.engineering,
                        AppColors.info,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Managers',
                        '$managers',
                        Icons.supervisor_account,
                        AppColors.primaryDarkGreen,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Total Staff',
                        '${technicians + managers}',
                        Icons.people,
                        AppColors.info.withOpacity(0.7),
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
