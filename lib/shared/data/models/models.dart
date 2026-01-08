import 'package:flutter/material.dart';

// User Role Enum
enum UserRole {
  superAdmin,
  manager,
  technician,
}

// Ticket Status Enum
enum TicketStatus {
  toDo,
  inProgress,
  done,
}

// Severity Level Enum
enum SeverityLevel {
  high,
  medium,
  low,
}

// Component Health Status
enum HealthStatus {
  healthy,
  warning,
  critical,
}

// Issue Verification
enum IssueVerification {
  issueFound,
  issueNotFound,
}

// Action Taken
enum ActionTaken {
  inspection,
  adjustment,
  lubrication,
  replacement,
  escalation,
  temporaryWorkaround,
}

// Outcome
enum Outcome {
  resolved,
  partiallyResolved,
  notResolved,
  needsShutdown,
}

// Noise Level
enum NoiseLevel {
  none,
  mild,
  strong,
}

// Expertise Type
enum ExpertiseType {
  mechanical,
  electrical,
  automation,
  plumbing,
  hvac,
  general,
}

// User Model
class UserModel {
  final String id;
  final String fullName;
  final String employeeId;
  final String email;
  final UserRole role;
  final String? assignedFloor;
  final List<ExpertiseType> expertise;
  final List<String> assignedMachineIds;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.employeeId,
    required this.email,
    required this.role,
    this.assignedFloor,
    this.expertise = const [],
    this.assignedMachineIds = const [],
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? fullName,
    String? employeeId,
    String? email,
    UserRole? role,
    String? assignedFloor,
    List<ExpertiseType>? expertise,
    List<String>? assignedMachineIds,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      role: role ?? this.role,
      assignedFloor: assignedFloor ?? this.assignedFloor,
      expertise: expertise ?? this.expertise,
      assignedMachineIds: assignedMachineIds ?? this.assignedMachineIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Machine Model
class MachineModel {
  final String id;
  final String name;
  final String type;
  final String manufacturer;
  final String model;
  final String location;
  final String floor;
  final HealthStatus healthStatus;
  final double riskScore;
  final List<ComponentModel> components;
  final DateTime installationDate;
  final double costPerHourDowntime;
  final String? imageUrl;
  final String? model3DUrl;

  MachineModel({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.location,
    required this.floor,
    this.healthStatus = HealthStatus.healthy,
    this.riskScore = 0.0,
    this.components = const [],
    required this.installationDate,
    this.costPerHourDowntime = 500.0,
    this.imageUrl,
    this.model3DUrl,
  });

  MachineModel copyWith({
    String? id,
    String? name,
    String? type,
    String? manufacturer,
    String? model,
    String? location,
    String? floor,
    HealthStatus? healthStatus,
    double? riskScore,
    List<ComponentModel>? components,
    DateTime? installationDate,
    double? costPerHourDowntime,
    String? imageUrl,
    String? model3DUrl,
  }) {
    return MachineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      location: location ?? this.location,
      floor: floor ?? this.floor,
      healthStatus: healthStatus ?? this.healthStatus,
      riskScore: riskScore ?? this.riskScore,
      components: components ?? this.components,
      installationDate: installationDate ?? this.installationDate,
      costPerHourDowntime: costPerHourDowntime ?? this.costPerHourDowntime,
      imageUrl: imageUrl ?? this.imageUrl,
      model3DUrl: model3DUrl ?? this.model3DUrl,
    );
  }
}

// Component Model
class ComponentModel {
  final String id;
  final String machineId;
  final String name;
  final String type;
  final HealthStatus healthStatus;
  final double riskLevel;
  final Map<String, double> sensorReadings;
  final String? position3D;

  ComponentModel({
    required this.id,
    required this.machineId,
    required this.name,
    required this.type,
    this.healthStatus = HealthStatus.healthy,
    this.riskLevel = 0.0,
    this.sensorReadings = const {},
    this.position3D,
  });
}

// Ticket Model
class TicketModel {
  final String id;
  final String title;
  final String description;
  final String machineId;
  final String machineName;
  final String? componentId;
  final String? componentName;
  final SeverityLevel severity;
  final TicketStatus status;
  final String? assigneeId;
  final String? assigneeName;
  final ExpertiseType requiredSkill;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? respondedAt;
  final DateTime? resolvedAt;
  final String? aiInsight;
  final double? aiConfidence;
  final List<TroubleshootingStep> troubleshootingSteps;
  final TechnicianFeedback? feedback;
  final double? estimatedDowntimeMinutes;
  final double? estimatedCost;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.machineId,
    required this.machineName,
    this.componentId,
    this.componentName,
    required this.severity,
    this.status = TicketStatus.toDo,
    this.assigneeId,
    this.assigneeName,
    this.requiredSkill = ExpertiseType.general,
    DateTime? createdAt,
    this.scheduledAt,
    this.respondedAt,
    this.resolvedAt,
    this.aiInsight,
    this.aiConfidence,
    this.troubleshootingSteps = const [],
    this.feedback,
    this.estimatedDowntimeMinutes,
    this.estimatedCost,
  }) : createdAt = createdAt ?? DateTime.now();

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? machineId,
    String? machineName,
    String? componentId,
    String? componentName,
    SeverityLevel? severity,
    TicketStatus? status,
    String? assigneeId,
    String? assigneeName,
    ExpertiseType? requiredSkill,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? respondedAt,
    DateTime? resolvedAt,
    String? aiInsight,
    double? aiConfidence,
    List<TroubleshootingStep>? troubleshootingSteps,
    TechnicianFeedback? feedback,
    double? estimatedDowntimeMinutes,
    double? estimatedCost,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      componentId: componentId ?? this.componentId,
      componentName: componentName ?? this.componentName,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      requiredSkill: requiredSkill ?? this.requiredSkill,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      respondedAt: respondedAt ?? this.respondedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      aiInsight: aiInsight ?? this.aiInsight,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      troubleshootingSteps: troubleshootingSteps ?? this.troubleshootingSteps,
      feedback: feedback ?? this.feedback,
      estimatedDowntimeMinutes:
          estimatedDowntimeMinutes ?? this.estimatedDowntimeMinutes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }
}

// Troubleshooting Step
class TroubleshootingStep {
  final String id;
  final String ticketId;
  final String description;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final bool isAiGenerated;

  TroubleshootingStep({
    required this.id,
    required this.ticketId,
    required this.description,
    this.isCompleted = false,
    required this.createdBy,
    DateTime? createdAt,
    this.isAiGenerated = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

// Technician Feedback
class TechnicianFeedback {
  final String id;
  final String ticketId;
  final String technicianId;
  final NoiseLevel noiseLevel;
  final bool vibrationFelt;
  final bool heatFelt;
  final bool visibleLeak;
  final bool smellDetected;
  final ActionTaken actionTaken;
  final Outcome outcome;
  final IssueVerification verification;
  final String? notes;
  final DateTime submittedAt;

  TechnicianFeedback({
    required this.id,
    required this.ticketId,
    required this.technicianId,
    this.noiseLevel = NoiseLevel.none,
    this.vibrationFelt = false,
    this.heatFelt = false,
    this.visibleLeak = false,
    this.smellDetected = false,
    required this.actionTaken,
    required this.outcome,
    required this.verification,
    this.notes,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();
}

// AI Insight Model
class AIInsightModel {
  final String id;
  final String ticketId;
  final String machineId;
  final String componentId;
  final String whatIsHappening;
  final String whyItMatters;
  final String potentialCause;
  final double confidenceLevel;
  final List<SensorSignal> contributingSignals;
  final List<String> similarPastCases;
  final String? uncertaintyNote;

  AIInsightModel({
    required this.id,
    required this.ticketId,
    required this.machineId,
    required this.componentId,
    required this.whatIsHappening,
    required this.whyItMatters,
    required this.potentialCause,
    required this.confidenceLevel,
    this.contributingSignals = const [],
    this.similarPastCases = const [],
    this.uncertaintyNote,
  });
}

// Sensor Signal
class SensorSignal {
  final String type;
  final double currentValue;
  final double normalMin;
  final double normalMax;
  final double deviation;
  final String unit;

  SensorSignal({
    required this.type,
    required this.currentValue,
    required this.normalMin,
    required this.normalMax,
    required this.deviation,
    required this.unit,
  });

  bool get isAbnormal => currentValue < normalMin || currentValue > normalMax;
}

// ASME Guideline
class ASMEGuideline {
  final String id;
  final String machineType;
  final String componentType;
  final String failureMode;
  final List<String> inspectionSteps;
  final Map<String, ASMERange> safetyRanges;
  final int lubricationIntervalDays;
  final String? documentLink;

  ASMEGuideline({
    required this.id,
    required this.machineType,
    required this.componentType,
    required this.failureMode,
    required this.inspectionSteps,
    required this.safetyRanges,
    this.lubricationIntervalDays = 30,
    this.documentLink,
  });
}

// ASME Range
class ASMERange {
  final double min;
  final double max;
  final String unit;

  ASMERange({
    required this.min,
    required this.max,
    required this.unit,
  });
}

// Dashboard KPI Model
class DashboardKPI {
  final int totalMachines;
  final int totalSensors;
  final int healthyMachines;
  final int warningMachines;
  final int criticalMachines;
  final int activeTickets;
  final int criticalTickets;
  final double totalDowntimeHours;
  final double estimatedCostImpact;
  final double downtimeChangePercent;
  final double avgResponseTimeMinutes;
  final double avgResolutionTimeMinutes;

  DashboardKPI({
    required this.totalMachines,
    required this.totalSensors,
    required this.healthyMachines,
    required this.warningMachines,
    required this.criticalMachines,
    required this.activeTickets,
    required this.criticalTickets,
    required this.totalDowntimeHours,
    required this.estimatedCostImpact,
    required this.downtimeChangePercent,
    required this.avgResponseTimeMinutes,
    required this.avgResolutionTimeMinutes,
  });
}

// Sensor Data Point (for charts)
class SensorDataPoint {
  final DateTime timestamp;
  final double value;

  SensorDataPoint({
    required this.timestamp,
    required this.value,
  });
}

// Extensions for enums
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.technician:
        return 'Technician';
    }
  }
}

extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.toDo:
        return 'To Do';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.toDo:
        return const Color(0xFF9E9E9E);
      case TicketStatus.inProgress:
        return const Color(0xFF2196F3);
      case TicketStatus.done:
        return const Color(0xFF08CE4A);
    }
  }
}

extension SeverityLevelExtension on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case SeverityLevel.high:
        return const Color(0xFFE53935);
      case SeverityLevel.medium:
        return const Color(0xFFFF9500);
      case SeverityLevel.low:
        return const Color(0xFF08CE4A);
    }
  }
}

extension HealthStatusExtension on HealthStatus {
  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Healthy';
      case HealthStatus.warning:
        return 'Warning';
      case HealthStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case HealthStatus.healthy:
        return const Color(0xFF08CE4A);
      case HealthStatus.warning:
        return const Color(0xFFFF9500);
      case HealthStatus.critical:
        return const Color(0xFFE53935);
    }
  }
}

extension ExpertiseTypeExtension on ExpertiseType {
  String get displayName {
    switch (this) {
      case ExpertiseType.mechanical:
        return 'Mechanical';
      case ExpertiseType.electrical:
        return 'Electrical';
      case ExpertiseType.automation:
        return 'Automation';
      case ExpertiseType.plumbing:
        return 'Plumbing';
      case ExpertiseType.hvac:
        return 'HVAC';
      case ExpertiseType.general:
        return 'General';
    }
  }
}

extension ActionTakenExtension on ActionTaken {
  String get displayName {
    switch (this) {
      case ActionTaken.inspection:
        return 'Inspection';
      case ActionTaken.adjustment:
        return 'Adjustment';
      case ActionTaken.lubrication:
        return 'Lubrication';
      case ActionTaken.replacement:
        return 'Replacement';
      case ActionTaken.escalation:
        return 'Escalation';
      case ActionTaken.temporaryWorkaround:
        return 'Temporary Workaround';
    }
  }
}

extension OutcomeExtension on Outcome {
  String get displayName {
    switch (this) {
      case Outcome.resolved:
        return 'Resolved';
      case Outcome.partiallyResolved:
        return 'Partially Resolved';
      case Outcome.notResolved:
        return 'Not Resolved';
      case Outcome.needsShutdown:
        return 'Needs Shutdown';
    }
  }
}

extension NoiseLevelExtension on NoiseLevel {
  String get displayName {
    switch (this) {
      case NoiseLevel.none:
        return 'None';
      case NoiseLevel.mild:
        return 'Mild';
      case NoiseLevel.strong:
        return 'Strong';
    }
  }
}

// Calendar Reminder Model
class CalendarReminder {
  final String id;
  final String title;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  CalendarReminder({
    required this.id,
    required this.title,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  CalendarReminder copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return CalendarReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
