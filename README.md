# Makina AI - Predictive Maintenance Flutter App

A technician-first predictive maintenance platform built with Flutter and Firebase.

## Features

### Technician View
- **Tickets Board (Kanban)**: View all tickets in To Do, In Progress, and Done columns
- **Ticket Details**: 3D machine visualization with component health heat maps
- **AI Insights**: Plain-language explanations of issues with confidence levels
- **Troubleshooting**: Step-by-step guided and manual troubleshooting
- **Feedback**: Structured observation recording for AI learning
- **ASME Compliance**: Industry-standard maintenance checklists

### Manager View
- **Dashboard**: Plant-level KPIs, machine health overview, cost impact
- **Calendar**: Scheduled maintenance view
- **Analytics**: Downtime analysis, AI performance, resolution metrics
- **Reports**: Generate and export PDF/CSV reports
- **Settings**: Configure thresholds, notifications, AI sensitivity

### Super Admin View
- **User Management**: Add/edit technicians and managers
- **Role Assignment**: Assign expertise types and machines
- **System Configuration**: Upload manuals and documentation

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Steps

1. **Clone/Extract the project**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (already configured)
   - The `google-services.json` is already in `android/app/`
   - Firebase Authentication and Firestore are configured

4. **Create test users in Firebase Console**
   Go to Firebase Console > Authentication > Users and create:
   - `admin@makina.ai` / `Admin123!` (Super Admin)
   - `manager@makina.ai` / `Manager123!` (Manager)
   - `tech@makina.ai` / `Tech123!` (Technician)

5. **Run the app**
   ```bash
   flutter run
   ```

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@makina.ai | Admin123! |
| Manager | manager@makina.ai | Manager123! |
| Technician | tech@makina.ai | Tech123! |

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── router/
├── features/
│   ├── auth/
│   ├── splash/
│   ├── technician/
│   ├── manager/
│   └── super_admin/
└── shared/
    └── data/
        ├── models/
        └── services/
```

## Color Scheme

- Dark Green: #288061
- Light Green: #08CE4A
- Orange/Warning: #FF9500
- Critical/Red: #E53935
- Info/Blue: #2196F3

## Key Features Implemented

✅ Firebase Authentication with role-based routing
✅ Kanban ticket board (Jira-like)
✅ 3D machine visualization with heat maps
✅ AI insights panel with confidence levels
✅ Troubleshooting steps (AI-suggested + manual)
✅ Technician feedback system
✅ ASME compliance module with checklists
✅ Manager dashboard with KPIs
✅ Calendar view for scheduled maintenance
✅ Analytics with charts
✅ Reports page
✅ Settings configuration
✅ Super Admin user management
✅ Light/Dark theme support
✅ Responsive design (phone + tablet)

## Mock Data

The app uses mock data for demonstration. All features work with simulated:
- Machines with components and sensor readings
- Tickets with AI insights
- User accounts
- Dashboard KPIs

## Notes

- Cost visibility is hidden from technicians (role-based)
- All ASME compliance steps can be tracked
- Ticket assignment is voluntary (no pre-assignment)
- Real-time updates simulated with state management
