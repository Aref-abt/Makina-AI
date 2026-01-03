# Machine Data Import Feature

## Overview
This feature allows you to import machine documentation from CSV/Excel files. The AI-powered parser can read structured and semi-structured documentation to extract machine data, components, and maintenance information.

## How to Use

### 1. On the Login Screen
- Before logging in, you'll see an "Import Machine Data" section
- Click "Choose File" to upload your CSV or Excel file
- The system will automatically detect the file type and parse the data
- Once imported, you'll see a success message with the number of items imported

### 2. After Login
- Your imported machines will appear in the Machines tab
- Components will be associated with their respective machines
- All data will be displayed throughout the app instead of mock data

## Supported File Formats

### CSV (.csv)
- Standard comma-separated values
- First row should contain column headers
- UTF-8 encoding recommended

### Excel (.xlsx, .xls)
- Microsoft Excel format
- Data should be in the first sheet
- First row should contain column headers

## File Structure Examples

### Machine Documentation (example_machine_import.csv)
```csv
Machine Name,Type,Manufacturer,Model,Location,Floor,Installation Date,Cost Per Hour Downtime
Haas VF-2SS CNC Mill,CNC Milling Machine,Haas Automation,VF-2SS,Bay A1,Floor 1,2020-03-15,850
Schuler Hydraulic Press 1000T,Hydraulic Press,Schuler AG,TSD 1000,Bay A2,Floor 1,2019-08-20,720
FANUC R-2000iC Robot Welder,Industrial Robot,FANUC Corporation,R-2000iC/165F,Bay B1,Floor 1,2021-06-10,950
```

**Required Columns (flexible matching):**
- **Machine Name / Name / Equipment Name** - The display name of the machine
- **Type / Machine Type / Category** - Type/category of equipment
- **Manufacturer / OEM / Vendor** - Equipment manufacturer
- **Model / Model Number** - Model designation
- **Location / Bay / Area** - Physical location identifier
- **Floor / Level** - Floor designation
- **Installation Date / Install Date** (Optional) - Format: YYYY-MM-DD
- **Cost / Downtime Cost** (Optional) - Cost per hour of downtime in dollars

### Component Documentation (example_components_import.csv)
```csv
Component Name,Type,Machine,Status,Location,Description
Main Spindle Motor,Motor,Haas VF-2SS CNC Mill,Warning,Center Top,15kW AC servo motor driving main spindle
Spindle Bearing Assembly,Bearing,Haas VF-2SS CNC Mill,Critical,Spindle Housing,High-precision angular contact bearings
Coolant Circulation Pump,Pump,Haas VF-2SS CNC Mill,Healthy,Right Bottom,Grundfos CR 10-3 centrifugal pump
```

**Required Columns (flexible matching):**
- **Component Name / Name / Part Name** - Component identifier
- **Type / Component Type** - Component category (Motor, Bearing, Pump, etc.)
- **Machine / Machine Name / Equipment** - Associated machine name
- **Status / Health / Condition** (Optional) - Health status (Healthy, Warning, Critical)
- **Location / Position** (Optional) - Physical location on machine
- **Description / Notes** (Optional) - Detailed description

### Maintenance Tickets (example_tickets_import.csv)
```csv
Title,Description,Machine,Severity,Status
Spindle Motor Overheating,Main spindle temperature exceeding limits,Haas VF-2SS CNC Mill,High,Open
Hydraulic Leak Detected,Minor leak in main cylinder,Schuler Hydraulic Press 1000T,Medium,In Progress
```

**Required Columns:**
- **Title / Issue / Problem** - Brief issue description
- **Description / Details / Notes** - Detailed description
- **Machine / Equipment / Asset** - Machine name
- **Severity / Priority / Urgency** (Optional) - High, Medium, or Low
- **Status** (Optional) - Open, In Progress, Resolved

## AI-Powered Parsing

### Intelligent Column Detection
The system uses fuzzy matching to identify columns even if they don't match exactly:
- "Machine", "machine_name", "Equipment Name" all map to machine name
- "Mfg", "OEM", "Vendor" all map to manufacturer
- Flexible date formats (YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY)

### Unstructured Documentation
If your CSV doesn't have clear columns, the AI will attempt to extract information from the text:
- **Machine Detection**: Looks for keywords like "Machine", "Equipment", "Model", "Serial"
- **Component Detection**: Identifies motors, bearings, pumps, valves, sensors
- **Specification Extraction**: Parses technical specifications from text

Example of semi-structured text that the AI can parse:
```csv
Documentation
Equipment: Haas VF-2SS CNC Milling Machine
Manufacturer: Haas Automation Inc.
Model Number: VF-2SS
Location: Manufacturing Bay A1, Floor 1
Installed: March 2020
Components: Main Spindle Motor (15kW), Coolant Pump (Grundfos CR10-3)
```

## Best Practices

### 1. Data Quality
- ✅ Use consistent naming conventions
- ✅ Include all required columns for best results
- ✅ Verify data before import
- ❌ Avoid special characters in IDs
- ❌ Don't mix different data types in one file

### 2. File Organization
- **Separate files for different data types** - One for machines, one for components
- **Import order**: Machines first, then components (components reference machines)
- **Incremental imports**: You can import multiple files sequentially

### 3. Realistic Data
- Use actual manufacturer names and model numbers
- Include realistic specifications
- Real-world locations and identifiers
- Actual maintenance history if available

### 4. Testing
- Start with a small sample file (5-10 machines)
- Verify the data appears correctly in the app
- Then import your full dataset

## Example Files Included

The `assets/` folder contains example files you can use for testing:

1. **example_machine_import.csv** - 10 realistic industrial machines
   - CNC mills, lathes, robots, press brakes, etc.
   - Real manufacturers (Haas, FANUC, ABB, Mazak, etc.)
   - Realistic specifications and locations

2. **example_components_import.csv** - 50+ components
   - Motors, bearings, pumps, sensors
   - Associated with specific machines
   - Health status indicators
   - Technical specifications

## Technical Details

### Supported Component Types
- Motors (Servo, Stepper, Induction)
- Bearings (Ball, Roller, Angular Contact)
- Pumps (Centrifugal, Hydraulic, Coolant)
- Valves (Solenoid, Pressure, Flow)
- Sensors (Temperature, Pressure, Vibration, Vision)
- Actuators (Hydraulic, Pneumatic, Electric)
- Drives (Servo, VFD, Hydraulic Power Unit)
- Control Systems (PLC, HMI, Controllers)
- Structural Components
- Material Handling Equipment

### Health Status Mapping
- **Critical / Fail / Failed / Down** → Critical
- **Warning / Caution / Alert / Degraded** → Warning
- **Healthy / Good / Normal / OK / Operational** → Healthy

### Severity Mapping
- **High / Critical / Urgent / Emergency** → High
- **Medium / Moderate / Normal** → Medium
- **Low / Minor / Routine** → Low

## Troubleshooting

### Import Failed
- **Check file format**: Must be CSV, XLSX, or XLS
- **Verify encoding**: Use UTF-8 for CSV files
- **Check file size**: Keep under 10MB for best performance
- **Validate data**: Ensure required columns are present

### Data Not Appearing
- **Refresh the screen**: Navigate away and back
- **Check import message**: Success message shows number of items imported
- **Verify file content**: Open in Excel/text editor to check format

### Incorrect Parsing
- **Use standard column names**: Refer to examples above
- **Include column headers**: First row must be headers
- **Avoid merged cells**: In Excel files
- **One data type per file**: Don't mix machines and components

## Advanced Features

### Multiple Imports
- Import multiple files in sequence
- Data accumulates (doesn't overwrite)
- Clear and re-import by restarting the app

### Custom Extensions
To support additional file formats, you can extend the `DataImportService`:
- JSON format
- XML documentation
- PDF extraction (requires additional libraries)
- Database connections

### AI Confidence Scoring
The AI parser provides confidence scores for extracted data:
- **High confidence (>0.8)**: Clear, structured data
- **Medium confidence (0.5-0.8)**: Semi-structured, inferred data
- **Low confidence (<0.5)**: Guessed values, verify manually

## Data Privacy & Security

- All imports are processed locally on device
- No data is sent to external servers
- Imported data is stored in local app storage
- Cleared when app is uninstalled

## Future Enhancements

Coming soon:
- ✨ Excel file support (.xlsx)
- ✨ Batch import from folder
- ✨ Import validation and preview
- ✨ Export current data back to CSV
- ✨ Historical data versioning
- ✨ Cloud sync capabilities
- ✨ Template generator

## Support

For questions or issues with data import:
1. Check the example files in `assets/`
2. Review your data format against the examples
3. Verify column names match the flexible patterns
4. Test with a small file first

---

**Note**: The import feature is designed to be forgiving and flexible. Even if your documentation doesn't match the exact format, the AI will attempt to extract as much useful information as possible. For best results, structure your data similar to the provided examples.
