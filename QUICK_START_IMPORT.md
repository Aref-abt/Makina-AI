# Machine Data Import Feature - Quick Start

## What Was Added

### ✅ File Upload on Login Screen
- New "Import Machine Data" section before login
- Supports CSV and Excel files (.csv, .xlsx, .xls)
- Real-time import feedback with success/error messages
- Visual indicator when files are successfully imported

### ✅ AI-Powered Data Parser
- **Smart Column Detection**: Automatically identifies columns even with different naming
- **Flexible Formats**: Handles structured and semi-structured documentation
- **Multiple Data Types**: Machines, components, and maintenance tickets
- **Intelligent Extraction**: AI reads context to extract relevant information

### ✅ Dynamic Data Integration
- Imported data replaces mock data throughout the app
- Machines appear in Machines tab
- Components shown with correct associations
- All screens update automatically

## How to Test

### Option 1: Use Provided Example Files

1. **Start the app** and go to the login screen
2. **Click "Choose File"** in the Import section
3. **Select one of these files** from the `assets/` folder:
   - `example_machine_import.csv` - 10 realistic industrial machines
   - `example_components_import.csv` - 50+ machine components
   - `example_tickets_import.csv` - 20 maintenance tickets
4. **Wait for import** - You'll see a success message
5. **Login** with any demo credentials
6. **Navigate to Machines tab** - Your imported machines will be displayed!

### Option 2: Create Your Own File

Create a CSV file like this:

```csv
Machine Name,Type,Manufacturer,Model,Location,Floor,Installation Date,Cost Per Hour Downtime
Your CNC Mill,CNC Machine,HAAS,VF-3,Bay A1,Floor 1,2020-01-15,800
Your Robot,Industrial Robot,FANUC,R-2000iB,Bay B2,Floor 2,2019-06-20,950
Your Press,Hydraulic Press,Schuler,TSD 500,Bay C1,Floor 1,2021-03-10,700
```

**Key Points:**
- First row = Column headers
- Use realistic manufacturer/model names
- Dates in YYYY-MM-DD format
- Costs as numbers (no $ symbol)

## What Makes This Special

### 🤖 AI Features
1. **Fuzzy Matching**: Column names don't need to be exact
   - "Machine", "machine_name", "Equipment" → all work
   - "Mfg", "Manufacturer", "OEM" → all work

2. **Context Understanding**: Reads surrounding text
   - Extracts specifications from descriptions
   - Identifies component types from text
   - Infers relationships between machines and components

3. **Data Enrichment**: Fills in missing information
   - Default values for optional fields
   - Health status from keywords
   - Component associations

### 📊 Realistic Test Data
The example files include:
- **Real Manufacturers**: Haas, FANUC, ABB, Mazak, DMG MORI, Okuma
- **Actual Models**: VF-2SS, R-2000iC, IRB 6700, VARIAXIS i-700
- **Technical Specs**: Motor ratings, pressure values, flow rates
- **Component Details**: SKF bearings, Grundfos pumps, Allen Bradley drives

## File Structure Examples

### Machines (Minimal)
```csv
Machine Name,Type,Manufacturer,Model,Location,Floor
CNC Mill 1,CNC Milling,Haas,VF-2,Bay A1,Floor 1
```

### Machines (Complete)
```csv
Machine Name,Type,Manufacturer,Model,Location,Floor,Installation Date,Cost Per Hour Downtime
Haas VF-2SS CNC Mill,CNC Milling Machine,Haas Automation,VF-2SS,Bay A1,Floor 1,2020-03-15,850
```

### Components
```csv
Component Name,Type,Machine,Status
Main Spindle Motor,Motor,Haas VF-2SS CNC Mill,Warning
Coolant Pump,Pump,Haas VF-2SS CNC Mill,Healthy
```

### Tickets
```csv
Title,Description,Machine,Severity
Motor Overheating,Temperature too high,Haas VF-2SS CNC Mill,High
```

## Tips for Best Results

### ✅ Do This:
- Use clear, descriptive names
- Include all recommended columns
- Keep data consistent within each file
- Test with small files first (5-10 rows)
- Import machines before components

### ❌ Avoid This:
- Mixing data types in one file (machines + tickets)
- Special characters in IDs
- Empty rows between data
- Merged cells in Excel files
- Very large files (>1000 rows) at once

## Feature Highlights

1. **No Mock Data Limitation**: Real production data from day one
2. **Flexible Import**: Works with existing documentation formats
3. **Incremental Updates**: Import additional files anytime
4. **Local Processing**: All data stays on device
5. **AI Assistance**: Handles imperfect or incomplete data

## What Gets Imported

### From Machine Files:
- ✅ Machine identification and details
- ✅ Manufacturer and model information  
- ✅ Location and floor assignments
- ✅ Installation dates
- ✅ Downtime cost calculations

### From Component Files:
- ✅ Component names and types
- ✅ Machine associations
- ✅ Health status indicators
- ✅ Technical specifications
- ✅ Location within machine

### From Ticket Files:
- ✅ Issue descriptions
- ✅ Severity levels
- ✅ Machine/component references
- ✅ Status tracking
- ✅ Creation dates

## Next Steps

1. **Try the example files** to see how it works
2. **Prepare your real data** in CSV format
3. **Import your machines** first
4. **Import components** to add detail
5. **Import tickets** for maintenance history

## Technical Notes

- **File Size Limit**: Recommended <10MB for smooth processing
- **Encoding**: UTF-8 for best compatibility
- **Date Formats**: YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY all supported
- **Number Formats**: Decimals with . or , as separator

---

**Ready to test?** Open the example CSV files in the `assets/` folder to see the data structure, then upload them on the login screen!
