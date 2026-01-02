import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/export_service.dart';
import '../../../../shared/data/models/models.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = MockDataService().tickets;

    // Compute downtime per day (last 7 days) and response time trend
    final now = DateTime.now();
    final last7 = List.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i)));

    List<double> downtimeValues = List.filled(7, 0.0);
    List<double> responseValues = List.filled(7, 0.0);
    List<String> labels = last7
        .map((d) =>
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1])
        .toList();

    for (int i = 0; i < last7.length; i++) {
      final dayStart = last7[i];
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayTickets = tickets.where((t) =>
          t.createdAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
          t.createdAt.isBefore(dayEnd));
      // Downtime: sum estimatedDowntimeMinutes
      final totalDowntime = dayTickets.fold<double>(
          0.0, (p, t) => p + (t.estimatedDowntimeMinutes ?? 0).toDouble());
      downtimeValues[i] = totalDowntime;
      // Response time: average (resolvedAt - createdAt) in minutes for resolved tickets
      final resolved = dayTickets.where((t) => t.resolvedAt != null).toList();
      if (resolved.isNotEmpty) {
        final avg = resolved
                .map((t) => t.resolvedAt!.difference(t.createdAt).inMinutes)
                .reduce((a, b) => a + b) /
            resolved.length;
        responseValues[i] = avg.toDouble();
      } else {
        responseValues[i] = 0.0;
      }
    }

    // Fallback to demo data if all values are zero
    final hasDowntimeData = downtimeValues.any((v) => v > 0);
    final hasResponseData = responseValues.any((v) => v > 0);
    if (!hasDowntimeData) {
      downtimeValues = [45.0, 80.0, 60.0, 120.0, 95.0, 70.0, 55.0];
    }
    if (!hasResponseData) {
      responseValues = [120.0, 90.0, 135.0, 75.0, 60.0, 95.0, 80.0];
    }
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export'),
              onPressed: () => _showExportOptions(context, tickets)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time filter
            Row(
              children: ['Week', 'Month', 'Quarter', 'Year']
                  .map((period) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(period),
                            selected: period == 'Month',
                            onSelected: (_) {}),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Downtime Analysis
            Text('Downtime Analysis', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            _buildChartCard(
              isDark: isDark,
              child: Container(
                height: 240,
                padding: const EdgeInsets.all(20),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: downtimeValues.reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  labels[value.toInt()],
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)
                              .withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      downtimeValues.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: downtimeValues[index],
                            color: index == 3
                                ? AppColors.critical
                                : AppColors.primaryDarkGreen,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resolution Metrics
            Text('Resolution Metrics', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildMetricCard('Issue Found', '78%',
                        Icons.check_circle, AppColors.healthy, isDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildMetricCard('Issue Not Found', '22%',
                        Icons.help, AppColors.warning, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            // AI Performance
            Text('AI Performance', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            _buildChartCard(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    _buildProgressRow(
                        'AI Accuracy', 0.87, AppColors.healthy, isDark),
                    const SizedBox(height: 16),
                    _buildProgressRow(
                        'False Positive Rate', 0.12, AppColors.warning, isDark),
                    const SizedBox(height: 16),
                    _buildProgressRow('Technician Confirmation', 0.91,
                        AppColors.info, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Response Time Trend
            Text('Response Time Trend', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            _buildChartCard(
              isDark: isDark,
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(20),
                child: LineChart(
                  LineChartData(
                    maxY: responseValues.reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    lineTouchData: LineTouchData(enabled: true),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)
                              .withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  labels[value.toInt()],
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          responseValues.length,
                          (index) =>
                              FlSpot(index.toDouble(), responseValues[index]),
                        ),
                        isCurved: true,
                        color: AppColors.primaryDarkGreen,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primaryDarkGreen,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryDarkGreen.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, List<TicketModel> tickets) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export PDF'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _exportPDF(context, tickets);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Export CSV'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _exportCSV(context, tickets);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _exportPDF(
      BuildContext context, List<TicketModel> tickets) async {
    try {
      // Prepare headers and rows for details table
      final headers = [
        'ID',
        'Title',
        'Machine',
        'Status',
        'Severity',
        'Created Date'
      ];
      final rows = tickets
          .map((t) => [
                t.id,
                t.title,
                t.machineName,
                t.status.displayName,
                t.severity.displayName,
                DateFormat('MMM dd, yyyy').format(t.createdAt),
              ])
          .toList();

      await ExportService.generatePDFReport(
          title: 'Tickets Report',
          headers: headers,
          rows: rows,
          tickets: tickets,
          users: null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.critical));
    }
  }

  Future<void> _exportCSV(
      BuildContext context, List<TicketModel> tickets) async {
    try {
      final csv = ExportService.exportTicketsToCSV(tickets);
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/tickets_report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      await Share.shareFiles([file.path], text: 'Tickets Report');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('CSV export failed: $e'),
          backgroundColor: AppColors.critical));
    }
  }

  Widget _buildChartCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: child,
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          Text(title,
              style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
      String label, double value, Color color, bool isDark) {
    return Row(
      children: [
        SizedBox(
            width: 150, child: Text(label, style: AppTextStyles.bodyMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
        ),
        const SizedBox(width: 12),
        Text('${(value * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.labelMedium
                .copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
