# Data Import Quick Start Guide

## Overview

The Makina AI platform includes a powerful data import system that processes CSV and Excel files to populate machine documentation, component inventories, and maintenance history.

## Features

### Smart File Processing
- Automatic format detection for CSV and Excel files
- Intelligent column mapping with fuzzy matching
- Support for multiple data types in a single workflow
- Real-time validation and feedback

### AI-Powered Parsing
- **Flexible Column Detection**: Recognizes variations in column naming
- **Context-Aware Extraction**: Interprets semi-structured documentation
- **Multi-Format Support**: Handles machines, components, and tickets
- **Intelligent Inference**: Fills missing data based on context

### Seamless Integration
- Imported data supplements existing records
- Automatic ML training on historical data
- Real-time UI updates across all screens
- No data loss or replacement

---

## Quick Start

### Step 1: Access Import Feature
Navigate to the login screen where you'll find the data import section.

### Step 2: Select File
Click "Choose File" and select your CSV or Excel file:
- Supported formats: `.csv`, `.xlsx`, `.xls`
- Maximum file size: 10MB
- UTF-8 encoding recommended

### Step 3: Automatic Processing
The system automatically:
1. Detects file type and format
2. Parses data with intelligent column matching
3. Validates entries
4. Imports to database
5. Trains ML baselines

### Step 4: Verify Import
After successful import:
- Success message displays with import count
- Login to view imported data
- Navigate to Machines tab to see new entries
- ML predictions available immediately

---

## Example Files

The `assets/` directory contains three sample files:

### example_machine_import.csv
10 industrial machines with complete specifications:
- Manufacturers: Haas, FANUC, ABB, Mazak, DMG MORI, Okuma
- Model numbers: VF-2SS, R-2000iC, IRB 6700, VARIAXIS i-700
- Installation dates and locations
- Downtime cost data

### example_components_import.csv
50+ machine components:
- SKF bearings, Grundfos pumps, Allen Bradley drives
- Technical specifications
- Health status indicators
- Machine associations

### example_tickets_import.csv
20 historical maintenance tickets:
- Failure scenarios and diagnostics
- Severity levels and priorities
- Resolution status and timestamps
- Sensor data for ML training

---

## File Format Examples

### Machines CSV

```csv
Machine Name,Type,Manufacturer,Model,Location,Floor,Installation Date,Cost Per Hour Downtime
CNC Mill,CNC Machine,HAAS,VF-3,Bay A1,Floor 1,2020-01-15,800
Industrial Robot,Robot,FANUC,R-2000iB,Bay B2,Floor 2,2019-06-20,950
Hydraulic Press,Press,Schuler,TSD 500,Bay C1,Floor 1,2021-03-10,700
```

**Requirements**:
- First row must be column headers
- Dates in YYYY-MM-DD format
- Numeric values without symbols ($, €)
- Text fields can contain spaces

### Components CSV

```csv
Component Name,Type,Machine,Status,Location
Main Spindle Motor,Motor,CNC Mill,Warning,Center Top
Coolant Pump,Pump,CNC Mill,Healthy,Right Bottom
Robot Arm Joint 3,Servo,Industrial Robot,Critical,Arm Assembly
```

### Tickets CSV

```csv
Title,Description,Machine,Severity,Status,Created Date
Motor Overheating,Temperature exceeds 80C,CNC Mill,High,Open,2024-01-15
Leak Detected,Hydraulic leak in main cylinder,Hydraulic Press,Medium,In Progress,2024-01-14
Vibration Alert,Excessive vibration in spindle,CNC Mill,High,Resolved,2024-01-10
```

---

## Column Name Variations

The system recognizes multiple naming conventions:

### Machine Identification
Recognized as machine name:
- Machine, Machine Name, machine_name
- Equipment, Equipment Name, Asset
- Name, Device

### Manufacturer
Recognized as manufacturer:
- Manufacturer, Mfg, mfg
- OEM, Vendor, Make, Brand

### Dates
Recognized as installation date:
- Installation Date, Install Date, install_date
- Commission Date, Commissioned, Setup Date
- Date Installed, Date

### Status
Recognized as health status:
- Status, Health, Condition, State
- Health Status, Operating Status

---

## Smart Features

### Intelligent Matching
The parser uses fuzzy logic to handle:
- Case insensitivity (Machine = machine = MACHINE)
- Underscore variations (machine_name = machinename)
- Extra whitespace or special characters
- Abbreviated terms (Mfg = Manufacturer)

### Context Extraction
When columns aren't clearly defined, the AI extracts:
- Machine specifications from description text
- Component types from keywords
- Status indicators from phrases
- Relationships from context clues

### Data Enrichment
Automatically fills optional fields:
- Default health status (Healthy)
- Current timestamp for dates
- Generated IDs for tracking
- Inferred relationships

---

## Import Process Details

### 1. File Validation
- Checks file format (CSV/Excel)
- Verifies file size (<10MB)
- Validates encoding (UTF-8)
- Ensures headers present

### 2. Data Parsing
- Reads all rows
- Maps columns to data model
- Applies type conversions
- Validates required fields

### 3. Entity Creation
- Creates machine records
- Generates component entries
- Establishes relationships
- Assigns unique IDs

### 4. ML Training
- Extracts sensor readings
- Calculates baselines
- Updates anomaly models
- Prepares prediction engine

### 5. Database Integration
- Stores in data service
- Indexes for queries
- Maintains referential integrity
- Enables real-time access

---

## Troubleshooting

### Import Failed

**Symptom**: Error message on import

**Solutions**:
- Verify file format is CSV or Excel
- Check file size is under 10MB
- Ensure UTF-8 encoding
- Validate required columns present

### Missing Data

**Symptom**: Some records not imported

**Solutions**:
- Check for required fields (Name, Type)
- Verify data format matches examples
- Remove empty rows at end of file
- Ensure no special characters in critical fields

### Machine Not Showing

**Symptom**: Imported but not visible in UI

**Solutions**:
- Log out and log back in
- Navigate to Machines tab specifically
- Check that machine has valid name and type
- Verify import success message appeared

### Components Not Linked

**Symptom**: Components appear but not associated with machines

**Solutions**:
- Ensure machine name in component file exactly matches machine file
- Check for extra spaces in machine names
- Verify machine was imported first
- Use exact name match (case-sensitive preferred)

---

## Best Practices

### File Preparation
1. Use example files as templates
2. Keep first row as headers
3. Use consistent date formats
4. Remove empty rows/columns
5. Save as UTF-8 CSV

### Data Quality
1. Use real manufacturer names
2. Include complete model numbers
3. Provide accurate dates
4. Specify clear status values
5. Write detailed descriptions

### Import Strategy
1. Import machines first
2. Then import components
3. Finally import tickets
4. Verify each step
5. Train ML after all imports

### Maintenance
1. Update data periodically
2. Import new tickets regularly
3. Refresh component status
4. Add new machines as deployed
5. Archive old data appropriately

---

## Advanced Usage

### Batch Imports
Import multiple files sequentially:
1. Import all machine files
2. Import all component files
3. Import all ticket files
4. Single ML training run after all imports

### Custom Formats
For non-standard formats:
- Ensure first row is headers
- Use column names similar to examples
- Include required fields minimum
- Test with small file first

### Data Migration
Moving from other systems:
- Export to CSV from source system
- Map columns to Makina AI format
- Test with subset of data
- Validate ML predictions post-import
- Archive original data as backup

---

## Related Documentation

- **[DATA_IMPORT_GUIDE.md](DATA_IMPORT_GUIDE.md)** - Detailed file format specifications
- **[AI_ML_DOCUMENTATION.md](AI_ML_DOCUMENTATION.md)** - ML training and prediction details
- **[README.md](README.md)** - General application documentation
