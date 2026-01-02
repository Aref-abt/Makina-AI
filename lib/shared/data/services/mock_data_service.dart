import 'dart:math';
import '../models/models.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();

  // Mock Users
  final List<UserModel> users = [
    UserModel(
      id: 'user_001',
      fullName: 'Admin User',
      employeeId: 'EMP001',
      email: 'admin@makina.ai',
      role: UserRole.superAdmin,
      assignedFloor: 'All',
      expertise: ExpertiseType.values,
      assignedMachineIds: [],
      isActive: true,
    ),
    UserModel(
      id: 'user_002',
      fullName: 'Sarah Johnson',
      employeeId: 'EMP002',
      email: 'manager@makina.ai',
      role: UserRole.manager,
      assignedFloor: 'Floor 1',
      expertise: [ExpertiseType.mechanical, ExpertiseType.automation],
      assignedMachineIds: [],
      isActive: true,
    ),
    UserModel(
      id: 'user_003',
      fullName: 'Mike Chen',
      employeeId: 'EMP003',
      email: 'tech@makina.ai',
      role: UserRole.technician,
      assignedFloor: 'Floor 1',
      expertise: [ExpertiseType.mechanical, ExpertiseType.electrical],
      assignedMachineIds: ['machine_001', 'machine_002', 'machine_003'],
      isActive: true,
    ),
    UserModel(
      id: 'user_004',
      fullName: 'Emily Rodriguez',
      employeeId: 'EMP004',
      email: 'emily.r@makina.ai',
      role: UserRole.technician,
      assignedFloor: 'Floor 1',
      expertise: [ExpertiseType.electrical, ExpertiseType.automation],
      assignedMachineIds: ['machine_004', 'machine_005'],
      isActive: true,
    ),
    UserModel(
      id: 'user_005',
      fullName: 'David Kim',
      employeeId: 'EMP005',
      email: 'david.k@makina.ai',
      role: UserRole.technician,
      assignedFloor: 'Floor 2',
      expertise: [ExpertiseType.hvac, ExpertiseType.plumbing],
      assignedMachineIds: ['machine_006', 'machine_007'],
      isActive: true,
    ),
  ];

  // Mock Machines
  final List<MachineModel> machines = [
    MachineModel(
      id: 'machine_001',
      name: 'CNC Machine Alpha',
      type: 'CNC Milling',
      manufacturer: 'Haas',
      model: 'VF-2SS',
      location: 'Bay A1',
      floor: 'Floor 1',
      healthStatus: HealthStatus.critical,
      riskScore: 0.85,
      installationDate: DateTime(2020, 3, 15),
      costPerHourDowntime: 850.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_002',
      name: 'Industrial Press Beta',
      type: 'Hydraulic Press',
      manufacturer: 'Schuler',
      model: 'TSD 1000',
      location: 'Bay A2',
      floor: 'Floor 1',
      healthStatus: HealthStatus.warning,
      riskScore: 0.62,
      installationDate: DateTime(2019, 8, 20),
      costPerHourDowntime: 720.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_003',
      name: 'Conveyor System C',
      type: 'Belt Conveyor',
      manufacturer: 'Dorner',
      model: '3200 Series',
      location: 'Bay B1',
      floor: 'Floor 1',
      healthStatus: HealthStatus.healthy,
      riskScore: 0.15,
      installationDate: DateTime(2021, 1, 10),
      costPerHourDowntime: 450.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_004',
      name: 'Robot Arm Delta',
      type: 'Industrial Robot',
      manufacturer: 'FANUC',
      model: 'M-20iA',
      location: 'Bay B2',
      floor: 'Floor 1',
      healthStatus: HealthStatus.warning,
      riskScore: 0.48,
      installationDate: DateTime(2020, 11, 5),
      costPerHourDowntime: 1200.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_005',
      name: 'Packaging Unit E',
      type: 'Packaging Machine',
      manufacturer: 'Bosch',
      model: 'CUC 3001',
      location: 'Bay C1',
      floor: 'Floor 1',
      healthStatus: HealthStatus.healthy,
      riskScore: 0.22,
      installationDate: DateTime(2022, 4, 18),
      costPerHourDowntime: 380.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_006',
      name: 'HVAC Unit F1',
      type: 'Air Handler',
      manufacturer: 'Carrier',
      model: 'AquaForce 30XA',
      location: 'Rooftop',
      floor: 'Floor 2',
      healthStatus: HealthStatus.healthy,
      riskScore: 0.18,
      installationDate: DateTime(2018, 6, 12),
      costPerHourDowntime: 280.0,
      components: [],
    ),
    MachineModel(
      id: 'machine_007',
      name: 'Compressor Station G',
      type: 'Air Compressor',
      manufacturer: 'Atlas Copco',
      model: 'GA 90',
      location: 'Utility Room',
      floor: 'Floor 2',
      healthStatus: HealthStatus.critical,
      riskScore: 0.78,
      installationDate: DateTime(2017, 2, 28),
      costPerHourDowntime: 520.0,
      components: [],
    ),
  ];

  // Mock Components for Machine 001
  List<ComponentModel> getMachineComponents(String machineId) {
    if (machineId == 'machine_001') {
      return [
        ComponentModel(
          id: 'comp_001_1',
          machineId: machineId,
          name: 'Main Spindle Motor',
          type: 'Motor',
          healthStatus: HealthStatus.critical,
          riskLevel: 0.92,
          sensorReadings: {
            'temperature': 95.5,
            'vibration': 8.2,
            'current': 45.3,
          },
          position3D: 'center-top',
        ),
        ComponentModel(
          id: 'comp_001_2',
          machineId: machineId,
          name: 'Bearing Assembly A',
          type: 'Bearing',
          healthStatus: HealthStatus.warning,
          riskLevel: 0.65,
          sensorReadings: {
            'temperature': 72.0,
            'vibration': 5.1,
          },
          position3D: 'left-center',
        ),
        ComponentModel(
          id: 'comp_001_3',
          machineId: machineId,
          name: 'Coolant Pump',
          type: 'Pump',
          healthStatus: HealthStatus.healthy,
          riskLevel: 0.15,
          sensorReadings: {
            'pressure': 4.2,
            'flowRate': 12.5,
          },
          position3D: 'right-bottom',
        ),
        ComponentModel(
          id: 'comp_001_4',
          machineId: machineId,
          name: 'Control Panel',
          type: 'Electronics',
          healthStatus: HealthStatus.healthy,
          riskLevel: 0.08,
          sensorReadings: {
            'voltage': 220.0,
          },
          position3D: 'front-center',
        ),
      ];
    }
    return [
      ComponentModel(
        id: 'comp_${machineId}_1',
        machineId: machineId,
        name: 'Main Motor',
        type: 'Motor',
        healthStatus: HealthStatus.values[_random.nextInt(3)],
        riskLevel: _random.nextDouble(),
        sensorReadings: {
          'temperature': 60 + _random.nextDouble() * 40,
          'vibration': _random.nextDouble() * 10,
        },
      ),
      ComponentModel(
        id: 'comp_${machineId}_2',
        machineId: machineId,
        name: 'Bearing',
        type: 'Bearing',
        healthStatus: HealthStatus.values[_random.nextInt(3)],
        riskLevel: _random.nextDouble(),
        sensorReadings: {
          'temperature': 50 + _random.nextDouble() * 30,
        },
      ),
    ];
  }

  // Mock Tickets
  List<TicketModel> tickets = [];

  void initializeTickets() {
    tickets = [
      TicketModel(
        id: 'ticket_001',
        title: 'Critical: Spindle Motor Overheating',
        description: 'Main spindle motor temperature exceeding safe operating limits. Abnormal vibration patterns detected.',
        machineId: 'machine_001',
        machineName: 'CNC Machine Alpha',
        componentId: 'comp_001_1',
        componentName: 'Main Spindle Motor',
        severity: SeverityLevel.high,
        status: TicketStatus.inProgress,
        assigneeId: 'user_003',
        assigneeName: 'Mike Chen',
        requiredSkill: ExpertiseType.mechanical,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        aiInsight: 'Based on sensor data analysis, the spindle motor is showing signs of bearing wear. Temperature has increased 35% above baseline over the past 6 hours. Vibration frequency patterns match historical bearing degradation cases.',
        aiConfidence: 0.87,
        estimatedDowntimeMinutes: 180,
        estimatedCost: 2550.0,
        troubleshootingSteps: [
          TroubleshootingStep(
            id: 'step_001_1',
            ticketId: 'ticket_001',
            description: 'Verify motor temperature using thermal camera',
            isCompleted: true,
            createdBy: 'AI',
            isAiGenerated: true,
          ),
          TroubleshootingStep(
            id: 'step_001_2',
            ticketId: 'ticket_001',
            description: 'Check bearing lubrication levels',
            isCompleted: false,
            createdBy: 'AI',
            isAiGenerated: true,
          ),
        ],
      ),
      TicketModel(
        id: 'ticket_002',
        title: 'Warning: Hydraulic Pressure Fluctuation',
        description: 'Hydraulic system showing irregular pressure readings. May indicate seal wear or pump issues.',
        machineId: 'machine_002',
        machineName: 'Industrial Press Beta',
        componentId: 'comp_002_1',
        componentName: 'Hydraulic Pump',
        severity: SeverityLevel.medium,
        status: TicketStatus.toDo,
        requiredSkill: ExpertiseType.mechanical,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        aiInsight: 'Pressure fluctuations of ±15% detected. This pattern typically indicates early-stage seal degradation. Recommend inspection within 48 hours.',
        aiConfidence: 0.72,
        estimatedDowntimeMinutes: 90,
        estimatedCost: 1080.0,
      ),
      TicketModel(
        id: 'ticket_003',
        title: 'Robot Arm Calibration Drift',
        description: 'Position accuracy has degraded by 0.5mm over the past week. Requires recalibration.',
        machineId: 'machine_004',
        machineName: 'Robot Arm Delta',
        componentId: 'comp_004_1',
        componentName: 'Servo Motor A1',
        severity: SeverityLevel.medium,
        status: TicketStatus.toDo,
        assigneeId: 'user_004',
        assigneeName: 'Emily Rodriguez',
        requiredSkill: ExpertiseType.automation,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        scheduledAt: DateTime.now().add(const Duration(hours: 4)),
        aiInsight: 'Encoder feedback shows gradual drift pattern. Similar to case #2847 from March. Likely requires encoder recalibration and servo tuning.',
        aiConfidence: 0.81,
        estimatedDowntimeMinutes: 60,
        estimatedCost: 1200.0,
      ),
      TicketModel(
        id: 'ticket_004',
        title: 'Critical: Compressor High Temperature Alert',
        description: 'Air compressor discharge temperature exceeding limits. Auto-shutdown imminent.',
        machineId: 'machine_007',
        machineName: 'Compressor Station G',
        componentId: 'comp_007_1',
        componentName: 'Compression Unit',
        severity: SeverityLevel.high,
        status: TicketStatus.toDo,
        requiredSkill: ExpertiseType.hvac,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        aiInsight: 'Discharge temperature at 215°F, threshold is 200°F. Oil cooler efficiency has dropped 22%. Immediate inspection required to prevent auto-shutdown.',
        aiConfidence: 0.94,
        estimatedDowntimeMinutes: 240,
        estimatedCost: 2080.0,
      ),
      TicketModel(
        id: 'ticket_005',
        title: 'Conveyor Belt Tension Adjustment',
        description: 'Belt tracking slightly off-center. Minor adjustment needed during next maintenance window.',
        machineId: 'machine_003',
        machineName: 'Conveyor System C',
        severity: SeverityLevel.low,
        status: TicketStatus.done,
        assigneeId: 'user_003',
        assigneeName: 'Mike Chen',
        requiredSkill: ExpertiseType.mechanical,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 18)),
        aiInsight: 'Belt tracking deviation of 3mm detected. Within acceptable range but recommend adjustment during scheduled maintenance.',
        aiConfidence: 0.68,
        estimatedDowntimeMinutes: 30,
        estimatedCost: 225.0,
        feedback: TechnicianFeedback(
          id: 'feedback_005',
          ticketId: 'ticket_005',
          technicianId: 'user_003',
          noiseLevel: NoiseLevel.none,
          vibrationFelt: false,
          heatFelt: false,
          visibleLeak: false,
          smellDetected: false,
          actionTaken: ActionTaken.adjustment,
          outcome: Outcome.resolved,
          verification: IssueVerification.issueFound,
          notes: 'Adjusted belt tension and realigned tracking rollers. Running smoothly now.',
        ),
      ),
      TicketModel(
        id: 'ticket_006',
        title: 'Packaging Machine Sensor Error',
        description: 'Product detection sensor intermittently failing. Causing occasional packaging errors.',
        machineId: 'machine_005',
        machineName: 'Packaging Unit E',
        componentId: 'comp_005_1',
        componentName: 'Optical Sensor Array',
        severity: SeverityLevel.medium,
        status: TicketStatus.inProgress,
        assigneeId: 'user_004',
        assigneeName: 'Emily Rodriguez',
        requiredSkill: ExpertiseType.electrical,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        respondedAt: DateTime.now().subtract(const Duration(hours: 1)),
        aiInsight: 'Sensor signal shows intermittent dropouts. Pattern suggests possible loose connection or contamination on sensor lens. Check wiring and clean sensor surface.',
        aiConfidence: 0.76,
        estimatedDowntimeMinutes: 45,
        estimatedCost: 285.0,
      ),
    ];
  }

  // Get AI Insight for a ticket
  AIInsightModel getAIInsight(String ticketId) {
    final ticket = tickets.firstWhere((t) => t.id == ticketId);
    return AIInsightModel(
      id: 'insight_$ticketId',
      ticketId: ticketId,
      machineId: ticket.machineId,
      componentId: ticket.componentId ?? '',
      whatIsHappening: 'The ${ticket.componentName ?? "component"} is showing abnormal behavior patterns. Sensor readings indicate deviation from normal operating parameters.',
      whyItMatters: 'If left unaddressed, this could lead to component failure within 24-48 hours, causing unplanned downtime and potential damage to connected systems.',
      potentialCause: 'Based on historical data and current sensor patterns, the most likely cause is bearing wear leading to increased friction and heat generation.',
      confidenceLevel: ticket.aiConfidence ?? 0.75,
      contributingSignals: [
        SensorSignal(
          type: 'Temperature',
          currentValue: 95.5,
          normalMin: 60.0,
          normalMax: 80.0,
          deviation: 19.4,
          unit: '°C',
        ),
        SensorSignal(
          type: 'Vibration',
          currentValue: 8.2,
          normalMin: 0.0,
          normalMax: 5.0,
          deviation: 64.0,
          unit: 'mm/s',
        ),
        SensorSignal(
          type: 'Current Draw',
          currentValue: 45.3,
          normalMin: 30.0,
          normalMax: 40.0,
          deviation: 13.25,
          unit: 'A',
        ),
      ],
      similarPastCases: [
        'Case #2341 (Jan 2024): Similar vibration pattern resolved with bearing replacement',
        'Case #1892 (Oct 2023): Motor overheating due to blocked cooling vents',
      ],
      uncertaintyNote: 'Could also be caused by misalignment. Verify during physical inspection.',
    );
  }

  // Get ASME Guidelines
  ASMEGuideline getASMEGuideline(String componentType, String failureMode) {
    return ASMEGuideline(
      id: 'asme_001',
      machineType: 'CNC Machine',
      componentType: componentType,
      failureMode: failureMode,
      inspectionSteps: [
        '1. Lockout/Tagout: Ensure machine is properly isolated before inspection',
        '2. Visual Inspection: Check for visible signs of wear, damage, or contamination',
        '3. Temperature Check: Use thermal camera to verify hotspots (ASME limit: 85°C)',
        '4. Vibration Analysis: Compare readings with baseline (ASME limit: 4.5 mm/s RMS)',
        '5. Lubrication Check: Verify oil level and quality per ASME B16.34',
        '6. Electrical Connections: Inspect for loose or corroded terminals',
        '7. Document Findings: Record all measurements and observations',
      ],
      safetyRanges: {
        'temperature': ASMERange(min: 20.0, max: 85.0, unit: '°C'),
        'vibration': ASMERange(min: 0.0, max: 4.5, unit: 'mm/s RMS'),
        'pressure': ASMERange(min: 2.0, max: 6.0, unit: 'bar'),
      },
      lubricationIntervalDays: 30,
      documentLink: 'https://asme.org/standards/b16-34',
    );
  }

  // Get Dashboard KPIs
  DashboardKPI getDashboardKPIs() {
    return DashboardKPI(
      totalMachines: machines.length,
      totalSensors: 42,
      healthyMachines: machines.where((m) => m.healthStatus == HealthStatus.healthy).length,
      warningMachines: machines.where((m) => m.healthStatus == HealthStatus.warning).length,
      criticalMachines: machines.where((m) => m.healthStatus == HealthStatus.critical).length,
      activeTickets: tickets.where((t) => t.status != TicketStatus.done).length,
      criticalTickets: tickets.where((t) => t.severity == SeverityLevel.high && t.status != TicketStatus.done).length,
      totalDowntimeHours: 12.5,
      estimatedCostImpact: 8420.0,
      downtimeChangePercent: -15.3,
      avgResponseTimeMinutes: 23.5,
      avgResolutionTimeMinutes: 85.2,
    );
  }

  // Generate sensor history data for charts
  List<SensorDataPoint> generateSensorHistory(String sensorType, int hoursBack) {
    final List<SensorDataPoint> data = [];
    final now = DateTime.now();
    double baseValue;
    double variance;

    switch (sensorType) {
      case 'temperature':
        baseValue = 70.0;
        variance = 15.0;
        break;
      case 'vibration':
        baseValue = 3.5;
        variance = 3.0;
        break;
      case 'pressure':
        baseValue = 4.0;
        variance = 1.0;
        break;
      default:
        baseValue = 50.0;
        variance = 10.0;
    }

    for (int i = hoursBack * 60; i >= 0; i -= 5) {
      final timestamp = now.subtract(Duration(minutes: i));
      // Add trend towards the end (showing degradation)
      final trendFactor = (hoursBack * 60 - i) / (hoursBack * 60);
      final value = baseValue + 
          (_random.nextDouble() - 0.5) * variance + 
          trendFactor * variance * 0.5;
      data.add(SensorDataPoint(timestamp: timestamp, value: value));
    }
    return data;
  }

  // Get tickets by status
  List<TicketModel> getTicketsByStatus(TicketStatus status) {
    return tickets.where((t) => t.status == status).toList();
  }

  // Get tickets for technician
  List<TicketModel> getTicketsForTechnician(String technicianId) {
    final user = users.firstWhere((u) => u.id == technicianId);
    return tickets.where((t) => 
      user.assignedMachineIds.contains(t.machineId) ||
      t.assigneeId == technicianId
    ).toList();
  }

  // Update ticket status
  void updateTicketStatus(String ticketId, TicketStatus newStatus) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      tickets[index] = tickets[index].copyWith(
        status: newStatus,
        respondedAt: newStatus == TicketStatus.inProgress ? DateTime.now() : null,
        resolvedAt: newStatus == TicketStatus.done ? DateTime.now() : null,
      );
    }
  }

  // Assign ticket
  void assignTicket(String ticketId, String assigneeId) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    final assignee = users.firstWhere((u) => u.id == assigneeId);
    if (index != -1) {
      tickets[index] = tickets[index].copyWith(
        assigneeId: assigneeId,
        assigneeName: assignee.fullName,
      );
    }
  }

  // Initialize mock data
  void initialize() {
    initializeTickets();
  }
}
