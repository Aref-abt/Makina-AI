import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

/// Service to import machine data from CSV/Excel files
/// Parses machine documentation and extracts relevant information
class DataImportService {
  static final DataImportService _instance = DataImportService._internal();
  factory DataImportService() => _instance;
  DataImportService._internal();

  final _uuid = const Uuid();

  // Store imported data
  List<MachineModel> importedMachines = [];
  List<ComponentModel> importedComponents = [];
  List<TicketModel> importedTickets = [];

  /// Parse CSV file and extract machine data
  Future<ImportResult> importFromCSV(File file) async {
    try {
      final contents = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(contents);

      if (rows.isEmpty) {
        return ImportResult(success: false, message: 'Empty file');
      }

      // Detect file type based on headers
      final headers =
          rows[0].map((e) => e.toString().toLowerCase().trim()).toList();

      if (_isMachineFile(headers)) {
        return await _parseMachineFile(rows);
      } else if (_isComponentFile(headers)) {
        return await _parseComponentFile(rows);
      } else if (_isTicketFile(headers)) {
        return await _parseTicketFile(rows);
      } else {
        // Try to parse as general documentation
        return await _parseGeneralDocumentation(rows);
      }
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      return ImportResult(success: false, message: 'Failed to import: $e');
    }
  }

  bool _isMachineFile(List<String> headers) {
    final machineKeywords = [
      'machine',
      'equipment',
      'asset',
      'model',
      'manufacturer'
    ];
    return headers.any((h) => machineKeywords.any((k) => h.contains(k)));
  }

  bool _isComponentFile(List<String> headers) {
    final componentKeywords = ['component', 'part', 'assembly', 'sensor'];
    return headers.any((h) => componentKeywords.any((k) => h.contains(k)));
  }

  bool _isTicketFile(List<String> headers) {
    final ticketKeywords = [
      'ticket',
      'issue',
      'problem',
      'fault',
      'maintenance'
    ];
    return headers.any((h) => ticketKeywords.any((k) => h.contains(k)));
  }

  Future<ImportResult> _parseMachineFile(List<List<dynamic>> rows) async {
    final headers =
        rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
    final machines = <MachineModel>[];

    // Find column indices
    final nameIdx = _findColumnIndex(
        headers, ['name', 'machine name', 'equipment name', 'asset name']);
    final typeIdx = _findColumnIndex(
        headers, ['type', 'machine type', 'equipment type', 'category']);
    final manufacturerIdx = _findColumnIndex(
        headers, ['manufacturer', 'oem', 'vendor', 'supplier']);
    final modelIdx =
        _findColumnIndex(headers, ['model', 'model number', 'model no']);
    final locationIdx =
        _findColumnIndex(headers, ['location', 'bay', 'area', 'zone']);
    final floorIdx = _findColumnIndex(headers, ['floor', 'level']);
    final installDateIdx = _findColumnIndex(
        headers, ['install date', 'installation date', 'commissioned']);
    final costIdx =
        _findColumnIndex(headers, ['cost', 'downtime cost', 'cost per hour']);

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((e) => e.toString().trim().isEmpty))
        continue;

      try {
        final machine = MachineModel(
          id: _uuid.v4(),
          name: _getValueOrDefault(row, nameIdx, 'Machine ${i}'),
          type: _getValueOrDefault(row, typeIdx, 'General Equipment'),
          manufacturer: _getValueOrDefault(row, manufacturerIdx, 'Unknown'),
          model: _getValueOrDefault(row, modelIdx, 'N/A'),
          location: _getValueOrDefault(row, locationIdx, 'Floor 1'),
          floor: _getValueOrDefault(row, floorIdx, 'Floor 1'),
          healthStatus: HealthStatus.healthy,
          riskScore: 0.0,
          installationDate:
              _parseDate(_getValueOrDefault(row, installDateIdx, '')) ??
                  DateTime.now().subtract(const Duration(days: 365)),
          costPerHourDowntime:
              _parseDouble(_getValueOrDefault(row, costIdx, '500')) ?? 500.0,
          components: [],
        );
        machines.add(machine);
      } catch (e) {
        debugPrint('Error parsing machine row $i: $e');
      }
    }

    importedMachines.addAll(machines);
    return ImportResult(
      success: true,
      message: 'Successfully imported ${machines.length} machines',
      machinesImported: machines.length,
    );
  }

  Future<ImportResult> _parseComponentFile(List<List<dynamic>> rows) async {
    final headers =
        rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
    final components = <ComponentModel>[];

    final nameIdx =
        _findColumnIndex(headers, ['name', 'component name', 'part name']);
    final typeIdx =
        _findColumnIndex(headers, ['type', 'component type', 'part type']);
    final machineIdIdx =
        _findColumnIndex(headers, ['machine id', 'machine', 'equipment id']);
    final statusIdx =
        _findColumnIndex(headers, ['status', 'health', 'condition']);

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((e) => e.toString().trim().isEmpty))
        continue;

      try {
        final component = ComponentModel(
          id: _uuid.v4(),
          machineId: _getValueOrDefault(row, machineIdIdx,
              importedMachines.isNotEmpty ? importedMachines[0].id : 'unknown'),
          name: _getValueOrDefault(row, nameIdx, 'Component ${i}'),
          type: _getValueOrDefault(row, typeIdx, 'General'),
          healthStatus:
              _parseHealthStatus(_getValueOrDefault(row, statusIdx, 'healthy')),
          riskLevel: 0.0,
          sensorReadings: {},
        );
        components.add(component);
      } catch (e) {
        debugPrint('Error parsing component row $i: $e');
      }
    }

    importedComponents.addAll(components);
    return ImportResult(
      success: true,
      message: 'Successfully imported ${components.length} components',
      componentsImported: components.length,
    );
  }

  Future<ImportResult> _parseTicketFile(List<List<dynamic>> rows) async {
    final headers =
        rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
    final tickets = <TicketModel>[];

    final titleIdx =
        _findColumnIndex(headers, ['title', 'issue', 'problem', 'subject']);
    final descIdx =
        _findColumnIndex(headers, ['description', 'details', 'notes']);
    final machineIdx =
        _findColumnIndex(headers, ['machine', 'equipment', 'asset']);
    final severityIdx =
        _findColumnIndex(headers, ['severity', 'priority', 'urgency']);

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((e) => e.toString().trim().isEmpty))
        continue;

      try {
        final ticket = TicketModel(
          id: _uuid.v4(),
          title: _getValueOrDefault(row, titleIdx, 'Issue ${i}'),
          description: _getValueOrDefault(row, descIdx, 'No description'),
          machineId:
              importedMachines.isNotEmpty ? importedMachines[0].id : 'unknown',
          machineName: _getValueOrDefault(row, machineIdx, 'Unknown Machine'),
          severity:
              _parseSeverity(_getValueOrDefault(row, severityIdx, 'medium')),
          status: TicketStatus.toDo,
          requiredSkill: ExpertiseType.general,
        );
        tickets.add(ticket);
      } catch (e) {
        debugPrint('Error parsing ticket row $i: $e');
      }
    }

    importedTickets.addAll(tickets);
    return ImportResult(
      success: true,
      message: 'Successfully imported ${tickets.length} tickets',
      ticketsImported: tickets.length,
    );
  }

  Future<ImportResult> _parseGeneralDocumentation(
      List<List<dynamic>> rows) async {
    // AI-powered parsing of unstructured documentation
    // This simulates AI reading the document and extracting structured data

    int machinesFound = 0;
    int componentsFound = 0;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowText = row.join(' ').toLowerCase();

      // Look for machine indicators
      if (_containsAny(rowText, ['machine', 'equipment', 'model', 'serial'])) {
        final machine = _extractMachineFromText(rows, i);
        if (machine != null) {
          importedMachines.add(machine);
          machinesFound++;
        }
      }

      // Look for component indicators
      if (_containsAny(rowText,
          ['motor', 'bearing', 'pump', 'valve', 'sensor', 'actuator'])) {
        final component = _extractComponentFromText(rows, i);
        if (component != null) {
          importedComponents.add(component);
          componentsFound++;
        }
      }
    }

    return ImportResult(
      success: machinesFound > 0 || componentsFound > 0,
      message:
          'AI extracted $machinesFound machines and $componentsFound components from documentation',
      machinesImported: machinesFound,
      componentsImported: componentsFound,
    );
  }

  MachineModel? _extractMachineFromText(
      List<List<dynamic>> rows, int startIdx) {
    // Simulate AI extraction from surrounding context
    final context = _getContextRows(rows, startIdx, 3);
    final text = context.join(' ');

    // Extract machine details using pattern matching
    final name = _extractPattern(
            text, r'(?:machine|equipment|asset)[\s:]+([A-Za-z0-9\s\-]+)') ??
        'Extracted Machine';
    final manufacturer = _extractPattern(
            text, r'(?:manufacturer|oem|made by)[\s:]+([A-Za-z0-9\s]+)') ??
        'Unknown';
    final model =
        _extractPattern(text, r'(?:model|type)[\s:]+([A-Za-z0-9\-]+)') ?? 'N/A';

    return MachineModel(
      id: _uuid.v4(),
      name: name,
      type: 'Extracted Equipment',
      manufacturer: manufacturer,
      model: model,
      location: 'Floor 1',
      floor: 'Floor 1',
      healthStatus: HealthStatus.healthy,
      riskScore: 0.0,
      installationDate: DateTime.now().subtract(const Duration(days: 365)),
      costPerHourDowntime: 500.0,
      components: [],
    );
  }

  ComponentModel? _extractComponentFromText(
      List<List<dynamic>> rows, int startIdx) {
    final context = _getContextRows(rows, startIdx, 2);
    final text = context.join(' ');

    final componentTypes = [
      'motor',
      'bearing',
      'pump',
      'valve',
      'sensor',
      'actuator',
      'gearbox',
      'shaft'
    ];
    String? componentType;

    for (final type in componentTypes) {
      if (text.toLowerCase().contains(type)) {
        componentType = type;
        break;
      }
    }

    if (componentType == null) return null;

    return ComponentModel(
      id: _uuid.v4(),
      machineId:
          importedMachines.isNotEmpty ? importedMachines.last.id : 'unknown',
      name: componentType.toUpperCase(),
      type: componentType,
      healthStatus: HealthStatus.healthy,
      riskLevel: 0.0,
      sensorReadings: {},
    );
  }

  // Helper methods
  int _findColumnIndex(List<String> headers, List<String> keywords) {
    for (int i = 0; i < headers.length; i++) {
      if (keywords.any((k) => headers[i].contains(k))) {
        return i;
      }
    }
    return -1;
  }

  String _getValueOrDefault(List<dynamic> row, int index, String defaultValue) {
    if (index < 0 || index >= row.length) return defaultValue;
    final value = row[index].toString().trim();
    return value.isEmpty ? defaultValue : value;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return null;
      // Try common formats
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        return DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
      return DateTime.tryParse(dateStr);
    } catch (e) {
      return null;
    }
  }

  double? _parseDouble(String value) {
    try {
      return double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    } catch (e) {
      return null;
    }
  }

  HealthStatus _parseHealthStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('critical') || s.contains('fail'))
      return HealthStatus.critical;
    if (s.contains('warn') || s.contains('caution'))
      return HealthStatus.warning;
    return HealthStatus.healthy;
  }

  SeverityLevel _parseSeverity(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high') || s.contains('critical')) return SeverityLevel.high;
    if (s.contains('low') || s.contains('minor')) return SeverityLevel.low;
    return SeverityLevel.medium;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  List<String> _getContextRows(List<List<dynamic>> rows, int idx, int range) {
    final start = (idx - range).clamp(0, rows.length);
    final end = (idx + range + 1).clamp(0, rows.length);
    return rows.sublist(start, end).map((row) => row.join(' ')).toList();
  }

  String? _extractPattern(String text, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  /// Clear all imported data
  void clearImportedData() {
    importedMachines.clear();
    importedComponents.clear();
    importedTickets.clear();
  }

  /// Get all imported data
  ImportedData getAllData() {
    return ImportedData(
      machines: importedMachines,
      components: importedComponents,
      tickets: importedTickets,
    );
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int machinesImported;
  final int componentsImported;
  final int ticketsImported;

  ImportResult({
    required this.success,
    required this.message,
    this.machinesImported = 0,
    this.componentsImported = 0,
    this.ticketsImported = 0,
  });
}

class ImportedData {
  final List<MachineModel> machines;
  final List<ComponentModel> components;
  final List<TicketModel> tickets;

  ImportedData({
    required this.machines,
    required this.components,
    required this.tickets,
  });

  bool get hasData =>
      machines.isNotEmpty || components.isNotEmpty || tickets.isNotEmpty;
}
