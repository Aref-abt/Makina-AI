import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/export_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final MockDataService _mockData = MockDataService();
  bool _isExporting = false;

  Future<void> _generateReport(String reportType) async {
    setState(() => _isExporting = true);

    try {
      final tickets = _mockData.tickets;
      final users = _mockData.users;

      switch (reportType) {
        case 'weekly':
          await ExportService.generatePDFReport(
            title: 'Weekly Summary Report',
            headers: ['Ticket ID', 'Title', 'Status', 'Severity'],
            rows: tickets
                .take(10)
                .map((t) => [
                      t.id,
                      t.title,
                      t.status.displayName,
                      t.severity.displayName
                    ])
                .toList(),
            tickets: tickets,
            users: null,
          );
          break;
        case 'monthly':
          await ExportService.generatePDFReport(
            title: 'Monthly Analysis Report',
            headers: ['Ticket ID', 'Machine', 'Resolution Time'],
            rows: tickets
                .take(10)
                .map((t) => [
                      t.id,
                      t.machineName,
                      t.resolvedAt != null
                          ? '${t.resolvedAt!.difference(t.createdAt).inHours}h'
                          : 'Pending',
                    ])
                .toList(),
            tickets: tickets,
            users: null,
          );
          break;
        case 'cost':
          await ExportService.generatePDFReport(
            title: 'Cost Impact Report',
            headers: ['Machine', 'Downtime', 'Cost Impact', 'Status'],
            rows: _mockData.machines
                .take(10)
                .map((m) => [
                      m.name,
                      '${(m.riskScore * 100).toStringAsFixed(0)}%',
                      '\$${(m.costPerHourDowntime * 5).toStringAsFixed(2)}',
                      m.healthStatus.displayName,
                    ])
                .toList(),
            tickets: null,
            users: null,
          );
          break;
        case 'compliance':
          await ExportService.generatePDFReport(
            title: 'ASME Compliance Report',
            headers: ['Machine', 'Status', 'Last Audit', 'Next Audit'],
            rows: _mockData.machines
                .take(10)
                .map((m) => [
                      m.name,
                      m.healthStatus.displayName,
                      'Dec 15, 2024',
                      'Jan 15, 2025',
                    ])
                .toList(),
            tickets: null,
            users: null,
          );
          break;
        case 'performance':
          await ExportService.generatePDFReport(
            title: 'Technician Performance Report',
            headers: [
              'Technician',
              'Tickets Resolved',
              'Avg Resolution Time',
              'Rating'
            ],
            rows: users
                .take(10)
                .map((u) => [
                      u.fullName,
                      '${tickets.length}',
                      '4.5 hours',
                      '4.8/5.0',
                    ])
                .toList(),
            tickets: null,
            users: users,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated and shared successfully'),
            backgroundColor: AppColors.healthy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _downloadAsCSV(String reportType) async {
    try {
      final tickets = _mockData.tickets;
      final users = _mockData.users;

      String csv = '';
      String filename = '';

      switch (reportType) {
        case 'tickets':
          csv = ExportService.exportTicketsToCSV(tickets);
          filename = 'tickets_report.csv';
          break;
        case 'users':
          csv = ExportService.exportUsersToCSV(users);
          filename = 'users_report.csv';
          break;
      }

      await Share.shareWithResult(
        csv,
        subject: filename,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully'),
            backgroundColor: AppColors.healthy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          _buildReportCard('Weekly Summary', 'Tickets and metrics',
              Icons.calendar_view_week, AppColors.info, isDark, 'weekly'),
          _buildReportCard(
              'Monthly Analysis',
              'In-depth performance',
              Icons.calendar_month,
              AppColors.primaryDarkGreen,
              isDark,
              'monthly'),
          _buildReportCard('Cost Impact Report', 'Financial analysis',
              Icons.attach_money, AppColors.critical, isDark, 'cost'),
          _buildReportCard('ASME Compliance Report', 'Standards compliance',
              Icons.verified, AppColors.warning, isDark, 'compliance'),
          _buildReportCard('Technician Performance', 'Team metrics',
              Icons.people, AppColors.info, isDark, 'performance'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting ? null : () => _generateReport('weekly'),
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.download),
        label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon,
      Color color, bool isDark, String reportType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed:
                  _isExporting ? null : () => _generateReport(reportType),
              tooltip: 'Download PDF',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _isExporting
                  ? null
                  : () => _downloadAsCSV(
                      reportType == 'weekly' || reportType == 'monthly'
                          ? 'tickets'
                          : 'users'),
              tooltip: 'Share CSV',
            ),
          ],
        ),
        onTap: () => _generateReport(reportType),
      ),
    );
  }
}
