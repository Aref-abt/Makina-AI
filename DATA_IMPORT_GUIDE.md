# Data Import System Documentation

## Overview

The Data Import System provides comprehensive CSV and Excel file processing capabilities for populating the Makina AI platform with machine documentation, component inventories, maintenance tickets, and historical sensor data.

## System Architecture

### Import Pipeline

```
File Upload → Format Detection → Column Mapping → Data Parsing → Validation → 
Entity Creation → ML Training → Database Storage → UI Update
```

### Core Components

**DataImportService** (`lib/shared/data/services/data_import_service.dart`)
- Main import orchestrator
- File format detection
- Column mapping logic
- Entity factory methods
- Error handling

**MLService** (`lib/shared/data/services/ml_service.dart`)
- Baseline training
- Anomaly model updates
- Historical data processing

**MockDataService** (`lib/shared/data/services/mock_data_service.dart`)
- Data storage and retrieval
- ML integration
- Query interface

---

## Supported File Formats

### CSV Files (.csv)
- Standard comma-separated values
- UTF-8 encoding required
- First row must be headers
- Supports quoted fields with commas
- Max file size: 10MB

### Excel Files (.xlsx, .xls)
- Microsoft Excel format
- Data in first sheet only
- First row must be headers
- Cell formulas evaluated to values
- Max file size: 10MB

---

## Data Models

### Machine Model

**Required Fields**:
- `name` (String) - Machine identifier
- `type` (String) - Equipment category
- `manufacturer` (String) - Equipment manufacturer
- `model` (String) - Model designation

**Optional Fields**:
- `location` (String) - Physical location/bay
- `floor` (String) - Floor designation
- `installationDate` (DateTime) - Installation date
- `costPerHourDowntime` (double) - Cost impact per hour

**Generated Fields**:
- `id` (String) - UUID
- `status` (String) - Health status (default: "Healthy")
- `components` (List) - Associated components
- `model3dPath` (String) - 3D model file path (if available)

**Column Name Variations**:
```
name: Machine, Machine Name, machine_name, Equipment, Asset, Device
type: Type, Machine Type, Category, Equipment Type
manufacturer: Manufacturer, Mfg, OEM, Vendor, Make, Brand
model: Model, Model Number, Model No, Part Number
location: Location, Bay, Area, Zone, Site
floor: Floor, Level, Building Floor
installationDate: Installation Date, Install Date, Commission Date, Setup Date
costPerHourDowntime: Cost, Downtime Cost, Cost Per Hour, Hourly Cost
```

### Component Model

**Required Fields**:
- `name` (String) - Component identifier
- `type` (String) - Component category
- `machineId` (String) - Associated machine

**Optional Fields**:
- `status` (String) - Health status (Healthy, Warning, Critical)
- `location` (String) - Location on machine
- `description` (String) - Detailed description
- `lastMaintenance` (DateTime) - Last maintenance date
- `specifications` (Map) - Technical specifications

**Generated Fields**:
- `id` (String) - UUID
- `sensorReadings` (List) - Current sensor data

**Column Name Variations**:
```
name: Component, Component Name, Part, Part Name
type: Type, Component Type, Category, Part Type
machineId/machine: Machine, Machine Name, Equipment, Asset
status: Status, Health, Condition, State
location: Location, Position, Place, Zone
description: Description, Details, Notes, Info
```

### Ticket Model

**Required Fields**:
- `title` (String) - Brief issue description
- `description` (String) - Detailed description
- `machineId` (String) - Related machine
- `severity` (String) - High, Medium, or Low

**Optional Fields**:
- `status` (String) - Open, In Progress, Resolved
- `createdAt` (DateTime) - Creation timestamp
- `resolvedAt` (DateTime) - Resolution timestamp
- `assignedTo` (String) - Assigned technician
- `sensorData` (Map) - Sensor readings at time of issue

**Generated Fields**:
- `id` (String) - UUID
- `ticketNumber` (String) - Formatted ticket number

**Column Name Variations**:
```
title: Title, Issue, Problem, Subject
description: Description, Details, Notes, Issue Description
machineId/machine: Machine, Equipment, Asset
severity: Severity, Priority, Urgency, Level
status: Status, State, Condition
createdAt: Created, Date, Timestamp, Created Date
```

---

## Column Mapping Algorithm

### Fuzzy Matching Logic

The system uses the following matching strategies:

1. **Exact Match** (Priority 1)
   - Direct string equality
   - Case-insensitive comparison

2. **Normalized Match** (Priority 2)
   - Lowercase conversion
   - Remove whitespace, underscores, hyphens
   - Remove special characters

3. **Keyword Match** (Priority 3)
   - Search for known keywords within column name
   - Example: "Machine_Name_Full" matches "machine"

4. **Synonym Match** (Priority 4)
   - Check list of known synonyms
   - Example: "OEM" matches "manufacturer"

### Implementation Example

```dart
int? _findColumnIndex(List<String> headers, List<String> variations) {
  for (var variation in variations) {
    for (var i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
      final target = variation.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
      
      if (header == target || header.contains(target)) {
        return i;
      }
    }
  }
  return null;
}
```

---

## Import Workflows

### Machine Import Workflow

1. **File Selection**
   - User selects CSV/Excel file
   - System validates file format

2. **Header Detection**
   - First row read as headers
   - Column mapping performed

3. **Row Processing**
   ```
   For each row:
     - Extract machine name, type, manufacturer, model
     - Parse optional fields
     - Validate required data
     - Create MachineModel instance
     - Generate UUID
     - Set default values
   ```

4. **Relationship Resolution**
   - Check for existing machines with same name
   - Merge or skip based on strategy
   - Store machine-to-component references

5. **Persistence**
   - Add to importedMachines list
   - Trigger UI refresh
   - Log import statistics

### Component Import Workflow

1. **File Processing**
   - Read headers and map columns
   - Parse component data

2. **Machine Association**
   ```
   For each component:
     - Read machine name from row
     - Search imported + existing machines
     - Create association if machine found
     - Generate warning if machine not found
   ```

3. **Component Creation**
   - Create ComponentModel with associations
   - Initialize sensor readings if provided
   - Set health status

4. **ML Preparation**
   - Components flagged for ML baseline training
   - Sensor data extracted for training set

### Ticket Import Workflow

1. **Ticket Parsing**
   - Extract ticket details
   - Parse timestamps
   - Determine severity

2. **Machine Linkage**
   - Link ticket to machine by name
   - Validate machine exists
   - Store relationship

3. **Sensor Data Extraction**
   - Extract sensor readings from ticket
   - Format for ML training
   - Associate with component

4. **ML Training Trigger**
   ```
   After all tickets imported:
     - Collect all sensor data
     - Group by component type
     - Calculate baselines (mean, stddev)
     - Update ML models
   ```

---

## Machine Learning Integration

### Training Data Extraction

When tickets are imported, the system:

1. **Identifies Sensor Data**
   - Searches ticket description and data fields
   - Extracts numerical readings
   - Determines sensor type (temperature, vibration, etc.)

2. **Creates Sensor Readings**
   ```dart
   class SensorReading {
     final String sensorType;
     final double value;
     final DateTime timestamp;
     final String unit;
   }
   ```

3. **Groups by Component**
   - Groups readings by component type
   - Separates healthy vs. failure states
   - Builds training dataset

### Baseline Calculation

For each component type:

```dart
// Calculate mean
double mean = sum(values) / count(values);

// Calculate standard deviation
double variance = sum((value - mean)² for each value) / count(values);
double stdDev = sqrt(variance);

// Store baseline
ComponentBaseline baseline = ComponentBaseline(
  componentType: type,
  means: {sensorType: mean},
  stdDevs: {sensorType: stdDev},
  sampleCount: count,
  lastUpdated: DateTime.now(),
);
```

### Anomaly Detection Setup

After training:
- ML models ready for real-time prediction
- Z-score thresholds configured
- Anomaly detection active on all components

---

## Data Validation Rules

### Machine Validation

**Required Validations**:
```dart
- name.isNotEmpty && name.length >= 2
- type.isNotEmpty
- manufacturer.isNotEmpty
- model.isNotEmpty
```

**Optional Validations**:
```dart
- If date provided: valid DateTime format
- If cost provided: positive number
- Location: non-empty string
```

### Component Validation

**Required Validations**:
```dart
- name.isNotEmpty
- type.isNotEmpty
- Valid machine reference (machine exists)
```

**Status Validation**:
```dart
Allowed values: "Healthy", "Warning", "Critical", "Maintenance"
Default if not provided: "Healthy"
```

### Ticket Validation

**Required Validations**:
```dart
- title.length >= 5
- description.length >= 10
- Valid machine reference
- severity in ["High", "Medium", "Low"]
```

**Date Validation**:
```dart
- createdAt <= current timestamp
- If resolvedAt provided: resolvedAt >= createdAt
```

---

## Error Handling

### File Format Errors

**Invalid Format**:
```
Error: Unsupported file format
Solution: Ensure file is .csv, .xlsx, or .xls
```

**Encoding Issues**:
```
Error: Unable to parse file
Solution: Save file as UTF-8 encoded CSV
```

### Data Errors

**Missing Required Field**:
```
Error: Row X missing required field 'name'
Action: Skip row, log warning, continue import
```

**Invalid Data Type**:
```
Error: Expected number, got text in 'cost' field
Action: Use default value, log warning
```

**Machine Not Found** (for components/tickets):
```
Error: Machine 'XYZ' not found for component 'ABC'
Action: Skip component, log error, suggest importing machines first
```

### System Errors

**Memory Limit**:
```
Error: File too large (>10MB)
Solution: Split into smaller files, import sequentially
```

**Duplicate Prevention**:
```
Warning: Machine 'ABC' already exists
Action: Based on strategy - skip or merge
```

---

## Performance Considerations

### Large File Handling

**Batch Processing**:
- Process rows in chunks of 100
- Yield to UI thread between batches
- Show progress indicator

**Memory Management**:
- Stream-based file reading
- Release parsed data immediately after processing
- Garbage collection between batches

### Optimization Techniques

**Indexing**:
- Create machine name index before component import
- Cache machine ID lookups
- Pre-compute column mappings

**Parallel Processing** (Future Enhancement):
- Parse multiple rows concurrently
- Validate in parallel
- Merge results in order

---

## Testing & Validation

### Test Data Sets

**Minimal Test**:
```csv
name,type,manufacturer,model
Test Machine,CNC,TestCo,T-100
```

**Complete Test**:
```csv
Machine Name,Type,Manufacturer,Model,Location,Floor,Installation Date,Cost Per Hour Downtime
Test CNC,CNC Mill,HAAS,VF-2,Bay A1,Floor 1,2020-01-15,800
```

**Stress Test**:
- 100+ machines
- 500+ components
- 200+ tickets
- Verify performance <5 seconds

### Validation Checklist

After import, verify:
- [ ] All machines appear in machine list
- [ ] Components linked to correct machines
- [ ] Tickets show proper associations
- [ ] ML baselines calculated
- [ ] Anomaly detection functional
- [ ] UI responsive with imported data
- [ ] No data loss from original file

---

## API Reference

### DataImportService.importFromCSV()

**Signature**:
```dart
Future<ImportResult> importFromCSV(String filePath)
```

**Parameters**:
- `filePath`: Absolute path to CSV/Excel file

**Returns**: `ImportResult` containing:
```dart
class ImportResult {
  int machinesImported;
  int componentsImported;
  int ticketsImported;
  List<String> errors;
  List<String> warnings;
  bool success;
}
```

**Process Flow**:
1. Validate file exists and is readable
2. Detect file format (CSV vs Excel)
3. Read and parse headers
4. Map columns to data model
5. Process each row:
   - Parse data
   - Validate
   - Create entities
   - Handle errors
6. Trigger ML training
7. Return results

### Example Usage

```dart
final importService = DataImportService();
final result = await importService.importFromCSV('/path/to/machines.csv');

if (result.success) {
  print('Imported ${result.machinesImported} machines');
  print('Imported ${result.componentsImported} components');
} else {
  print('Errors: ${result.errors.join(', ')}');
}
```

---

## Best Practices

### File Preparation
1. Always include headers in first row
2. Use consistent naming conventions
3. Keep data types consistent per column
4. Remove empty rows at end of file
5. Save as UTF-8 encoded CSV

### Data Quality
1. Use complete, descriptive names
2. Include all available specifications
3. Provide accurate dates and timestamps
4. Use standard status terminology
5. Write clear, detailed descriptions

### Import Order
1. Import machines first
2. Import components second (requires machines)
3. Import tickets last (requires machines)
4. Allow ML training to complete

### Troubleshooting
1. Test with small sample file first
2. Check example files for format reference
3. Validate required fields present
4. Ensure UTF-8 encoding
5. Review error messages carefully

---

## Related Documentation

- **[QUICK_START_IMPORT.md](QUICK_START_IMPORT.md)** - Quick start guide
- **[AI_ML_DOCUMENTATION.md](AI_ML_DOCUMENTATION.md)** - ML implementation details
- **[README.md](README.md)** - Main application documentation
