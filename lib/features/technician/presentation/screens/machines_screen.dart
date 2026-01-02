import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class MachinesScreen extends ConsumerWidget {
  const MachinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mockData = MockDataService();
    final machines = mockData.machines;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Machines')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final machine = machines[index];
          return _buildMachineCard(context, machine, isDark);
        },
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, MachineModel machine, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: InkWell(
        onTap: () => context.go('/technician/machines/${machine.id}'),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: machine.healthStatus.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.precision_manufacturing, color: machine.healthStatus.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(machine.name, style: AppTextStyles.h6),
                    const SizedBox(height: 4),
                    Text('${machine.type} • ${machine.location}', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: machine.healthStatus.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(machine.healthStatus.displayName, style: AppTextStyles.labelSmall.copyWith(color: machine.healthStatus.color, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text('Risk: ${(machine.riskScore * 100).toStringAsFixed(0)}%', style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
