import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class ASMEGuidelinesPanel extends StatefulWidget {
  final String componentType;
  final String failureMode;

  const ASMEGuidelinesPanel({
    super.key,
    required this.componentType,
    required this.failureMode,
  });

  @override
  State<ASMEGuidelinesPanel> createState() => _ASMEGuidelinesPanelState();
}

class _ASMEGuidelinesPanelState extends State<ASMEGuidelinesPanel> {
  final MockDataService _mockData = MockDataService();
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final guideline =
        _mockData.getASMEGuideline(widget.componentType, widget.failureMode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ASME Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.info.withOpacity(0.1),
                AppColors.info.withOpacity(0.05)
              ]),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.verified_outlined,
                      color: AppColors.info, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ASME Compliance Guidelines',
                          style: AppTextStyles.h6),
                      const SizedBox(height: 4),
                      Text('Industry-standard maintenance procedures',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Safety Ranges
          _buildSection(
            title: 'Safe Operating Ranges',
            icon: Icons.thermostat,
            isDark: isDark,
            child: Column(
              children: guideline.safetyRanges.entries
                  .map((entry) => _buildRangeItem(
                        entry.key.substring(0, 1).toUpperCase() +
                            entry.key.substring(1),
                        entry.value.min,
                        entry.value.max,
                        entry.value.unit,
                        isDark,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Inspection Steps
          _buildSection(
            title: 'ASME Inspection Checklist',
            icon: Icons.checklist,
            isDark: isDark,
            child: Column(
              children: List.generate(
                  guideline.inspectionSteps.length,
                  (index) => _buildInspectionStep(
                      guideline.inspectionSteps[index], index, isDark)),
            ),
          ),
          const SizedBox(height: 20),

          // Maintenance Schedule
          _buildSection(
            title: 'Maintenance Schedule',
            icon: Icons.schedule,
            isDark: isDark,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              child: Row(
                children: [
                  const Icon(Icons.oil_barrel,
                      color: AppColors.warning, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lubrication Interval',
                            style: AppTextStyles.labelLarge
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            'Every ${guideline.lubricationIntervalDays} days per ASME standards',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Compliance Progress
          _buildComplianceProgress(isDark, guideline.inspectionSteps.length),
          const SizedBox(height: 20),

          // Download Documentation
          OutlinedButton.icon(
            onPressed: () =>
                _downloadASMEGuidelines(context, guideline, isDark),
            icon: const Icon(Icons.download),
            label: const Text('Download Full ASME Guidelines'),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required bool isDark,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: AppTextStyles.h6.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText))
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRangeItem(
      String label, double min, double max, String unit, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      child: Row(
        children: [
          Icon(_getRangeIcon(label), size: 20, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.healthy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
                '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} $unit',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.healthy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getRangeIcon(String label) {
    switch (label.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'vibration':
        return Icons.vibration;
      case 'pressure':
        return Icons.speed;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildInspectionStep(String step, int index, bool isDark) {
    final isCompleted = _completedSteps.contains(index);
    return InkWell(
      onTap: () => setState(() {
        if (isCompleted)
          _completedSteps.remove(index);
        else
          _completedSteps.add(index);
      }),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.healthy.withOpacity(0.1)
              : (isDark ? AppColors.darkCard : AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color: isCompleted
                  ? AppColors.healthy.withOpacity(0.3)
                  : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.healthy : Colors.transparent,
                border: Border.all(
                    color: isCompleted
                        ? AppColors.healthy
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                    width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(step,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null))),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadASMEGuidelines(
      BuildContext context, dynamic guideline, bool isDark) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating ASME Guidelines PDF...')),
      );

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  'ASME Compliance Guidelines',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Machine & Component Info
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Machine Type: ${guideline.machineType}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Component: ${guideline.componentType}',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 5),
                    pw.Text('Failure Mode: ${guideline.failureMode}',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 5),
                    pw.Text('Document ID: ${guideline.id}',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Safe Operating Ranges
              pw.Header(level: 1, child: pw.Text('Safe Operating Ranges')),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Parameter', 'Minimum', 'Maximum', 'Unit'],
                data: guideline.safetyRanges.entries
                    .map<List<dynamic>>((e) => [
                          e.key[0].toUpperCase() + e.key.substring(1),
                          e.value.min.toStringAsFixed(1),
                          e.value.max.toStringAsFixed(1),
                          e.value.unit,
                        ])
                    .toList(),
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                cellStyle: const pw.TextStyle(fontSize: 11),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(8),
              ),
              pw.SizedBox(height: 20),

              // Inspection Checklist
              pw.Header(level: 1, child: pw.Text('ASME Inspection Checklist')),
              pw.SizedBox(height: 10),
              ...List.generate(guideline.inspectionSteps.length, (index) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 15,
                        height: 15,
                        margin: const pw.EdgeInsets.only(right: 10, top: 2),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey600, width: 1.5),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(guideline.inspectionSteps[index],
                            style: const pw.TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),

              // Maintenance Schedule
              pw.Header(level: 1, child: pw.Text('Maintenance Schedule')),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border.all(color: PdfColors.amber300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Lubrication Interval',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(
                        'Every ${guideline.lubricationIntervalDays} days per ASME standards',
                        style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Document Reference
              if (guideline.documentLink != null) ...[
                pw.Header(level: 1, child: pw.Text('Reference Documentation')),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                      'Online Documentation: ${guideline.documentLink}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.blue700)),
                ),
                pw.SizedBox(height: 20),
              ],

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated by Makina AI - Predictive Maintenance Platform',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                'Date: ${DateTime.now().toString().split('.')[0]}',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ];
          },
        ),
      );

      // Save PDF to temporary directory
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File(
          '${dir.path}/ASME_Guidelines_${guideline.componentType}_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'ASME Compliance Guidelines - ${guideline.componentType}',
        text:
            'ASME guidelines for ${guideline.machineType} - ${guideline.componentType}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ASME Guidelines PDF generated successfully!'),
            backgroundColor: AppColors.healthy,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  Widget _buildComplianceProgress(bool isDark, int totalSteps) {
    final completedCount = _completedSteps.length;
    final progress = totalSteps > 0 ? completedCount / totalSteps : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              const Text('Compliance Progress', style: AppTextStyles.h6),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: progress == 1.0
                        ? AppColors.healthy.withOpacity(0.15)
                        : AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('$completedCount / $totalSteps',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: progress == 1.0
                            ? AppColors.healthy
                            : AppColors.warning,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.healthy : AppColors.info)),
          ),
          const SizedBox(height: 8),
          Text(
              progress == 1.0
                  ? '✓ All ASME compliance steps completed'
                  : '${(progress * 100).toStringAsFixed(0)}% of ASME steps completed',
              style: AppTextStyles.bodySmall.copyWith(
                  color: progress == 1.0
                      ? AppColors.healthy
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary))),
        ],
      ),
    );
  }
}
