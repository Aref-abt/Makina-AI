import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../widgets/machine_3d_viewer.dart';

class MachineDetailScreen extends ConsumerWidget {
  final String machineId;
  const MachineDetailScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockData = MockDataService();
    final machine = mockData.machines.firstWhere(
      (m) => m.id == machineId,
      orElse: () => MachineModel(
        id: machineId,
        name: 'Unknown Machine',
        type: 'General Equipment',
        manufacturer: 'Unknown',
        model: 'N/A',
        location: 'Floor 1',
        floor: 'Floor 1',
        installationDate: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(machine.name)),
      body: Machine3DViewer(machineId: machineId),
    );
  }
}
