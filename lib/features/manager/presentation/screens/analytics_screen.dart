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

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'Month';
  String? _selectedMachineId;
  SeverityLevel? _selectedSeverityFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTickets = MockDataService().tickets;
    final machines = MockDataService().machines;

    // Apply UI filters (machine / severity)
    final tickets = allTickets.where((t) {
      if (_selectedMachineId != null && _selectedMachineId!.isNotEmpty) {
        if (t.machineId != _selectedMachineId) return false;
      }
      if (_selectedSeverityFilter != null) {
        if (t.severity != _selectedSeverityFilter) return false;
      }
      return true;
    }).toList();

    // Compute downtime and response metrics according to selected period
    final now = DateTime.now();

    List<DateTime> periods = [];
    List<String> labels = [];

    if (_selectedPeriod == 'Week') {
      periods = List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 6 - i)));
      labels = periods
          .map((d) =>
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1])
          .toList();
    } else if (_selectedPeriod == 'Month') {
      // last 30 days
      periods = List.generate(
          30,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 29 - i)));
      labels = periods
          .map((d) => '${d.day}')
          .toList(); // show day-of-month; we'll hide some labels in the chart
    } else {
      // Year: last 12 months
      periods = List.generate(12, (i) {
        final dt = DateTime(now.year, now.month, 1)
            .subtract(Duration(days: 30 * (11 - i)));
        return DateTime(dt.year, dt.month, 1);
      });
      labels = periods
          .map((d) => DateFormat.MMM().format(d))
          .toList(); // Jan, Feb, ...
    }

    List<double> downtimeValues = List.filled(periods.length, 0.0);
    List<double> responseValues = List.filled(periods.length, 0.0);

    for (int i = 0; i < periods.length; i++) {
      final start = periods[i];
      DateTime end;
      if (_selectedPeriod == 'Year') {
        end = DateTime(start.year, start.month + 1, 1);
      } else {
        end = start.add(const Duration(days: 1));
      }

      final periodTickets = tickets.where((t) =>
          t.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.createdAt.isBefore(end));

      final totalDowntime = periodTickets.fold<double>(
          0.0, (p, t) => p + (t.estimatedDowntimeMinutes ?? 0).toDouble());
      downtimeValues[i] = totalDowntime;

      final resolved =
          periodTickets.where((t) => t.resolvedAt != null).toList();
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

    // Fallback demo data sized to the selected period
    final hasDowntimeData = downtimeValues.any((v) => v > 0);
    final hasResponseData = responseValues.any((v) => v > 0);
    if (!hasDowntimeData) {
      if (_selectedPeriod == 'Week') {
        downtimeValues = [45.0, 80.0, 60.0, 120.0, 95.0, 70.0, 55.0];
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      } else if (_selectedPeriod == 'Month') {
        downtimeValues = List.generate(
            30, (i) => [45.0, 80.0, 60.0, 120.0, 95.0, 70.0, 55.0][i % 7]);
      } else {
        downtimeValues =
            List.generate(12, (i) => [120.0, 95.0, 80.0, 110.0][i % 4]);
      }
    }
    if (!hasResponseData) {
      if (_selectedPeriod == 'Week') {
        responseValues = [120.0, 90.0, 135.0, 75.0, 60.0, 95.0, 80.0];
      } else if (_selectedPeriod == 'Month') {
        responseValues = List.generate(
            30, (i) => [120.0, 90.0, 135.0, 75.0, 60.0, 95.0, 80.0][i % 7]);
      } else {
        responseValues =
            List.generate(12, (i) => [90.0, 100.0, 110.0, 95.0][i % 4]);
      }
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
            // Machine selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMachineId,
                    decoration:
                        const InputDecoration(labelText: 'Machine (All)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Machines')),
                      ...machines.map((m) => DropdownMenuItem(
                          value: m.id, child: Text('${m.name} — ${m.floor}')))
                    ],
                    onChanged: (v) => setState(() => _selectedMachineId = v),
                  ),
                ),
                const SizedBox(width: 12),
                if (_selectedMachineId != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedMachineId = null;
                    }),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Time filter
            Row(
              children: ['Week', 'Month', 'Year']
                  .map((period) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(period),
                            selected: period == _selectedPeriod,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                              }
                            }),
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
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor:
                            isDark ? AppColors.darkSurface : AppColors.white,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final idx = group.x.toInt();
                          final label = (idx >= 0 && idx < labels.length)
                              ? labels[idx]
                              : '';
                          return BarTooltipItem(
                            '$label\n${rod.toY.toStringAsFixed(0)} min',
                            TextStyle(
                                color: isDark
                                    ? AppColors.lightText
                                    : Colors.black),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= labels.length)
                              return const Text('');

                            // Reduce label density for Month view: show every 5th day
                            if (_selectedPeriod == 'Month') {
                              if (labels.length > 15 &&
                                  idx % 5 != 0 &&
                                  idx != labels.length - 1) {
                                return const Text('');
                              }
                            }

                            // For Week and Year show all labels (months are short)
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
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
            // Small stats + charts: responsive layout for mobile
            Builder(builder: (ctx) {
              final w = MediaQuery.of(ctx).size.width;
              final isNarrow = w <= AppDimensions.mobileBreakpoint;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resolution Metrics', style: AppTextStyles.h6),
                    const SizedBox(height: 12),
                    Builder(builder: (_) {
                      final totalWithFeedback =
                          tickets.where((t) => t.feedback != null).length;
                      final found = tickets
                          .where((t) =>
                              t.feedback?.verification ==
                              IssueVerification.issueFound)
                          .length;
                      final notFound = tickets
                          .where((t) =>
                              t.feedback?.verification ==
                              IssueVerification.issueNotFound)
                          .length;
                      final foundPct = totalWithFeedback > 0
                          ? ((found / totalWithFeedback) * 100).round()
                          : 0;
                      final notFoundPct = totalWithFeedback > 0
                          ? ((notFound / totalWithFeedback) * 100).round()
                          : 0;

                      return Row(
                        children: [
                          Expanded(
                              child: _buildMetricCard(
                                  'Issue Found',
                                  '${foundPct}%',
                                  Icons.check_circle,
                                  AppColors.healthy,
                                  isDark)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildMetricCard(
                                  'Issue Not Found',
                                  '${notFoundPct}%',
                                  Icons.help,
                                  AppColors.warning,
                                  isDark)),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    Text('Severity Distribution', style: AppTextStyles.h6),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 160,
                      child: Center(
                        child: PieChart(
                          PieChartData(
                            sections: _buildSeveritySections(tickets),
                            centerSpaceRadius: 28,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                if (response == null ||
                                    response.touchedSection == null) return;
                                final idx = response
                                    .touchedSection!.touchedSectionIndex;
                                setState(() {
                                  _selectedSeverityFilter =
                                      SeverityLevel.values[idx];
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_selectedSeverityFilter != null)
                      TextButton(
                          onPressed: () =>
                              setState(() => _selectedSeverityFilter = null),
                          child: const Text('Clear severity filter'))
                  ],
                );
              }

              // Wide layout: original side-by-side
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resolution Metrics', style: AppTextStyles.h6),
                          const SizedBox(height: 12),
                          Builder(builder: (_) {
                            final totalWithFeedback =
                                tickets.where((t) => t.feedback != null).length;
                            final found = tickets
                                .where((t) =>
                                    t.feedback?.verification ==
                                    IssueVerification.issueFound)
                                .length;
                            final notFound = tickets
                                .where((t) =>
                                    t.feedback?.verification ==
                                    IssueVerification.issueNotFound)
                                .length;
                            final foundPct = totalWithFeedback > 0
                                ? ((found / totalWithFeedback) * 100).round()
                                : 0;
                            final notFoundPct = totalWithFeedback > 0
                                ? ((notFound / totalWithFeedback) * 100).round()
                                : 0;

                            return Row(
                              children: [
                                Expanded(
                                    child: _buildMetricCard(
                                        'Issue Found',
                                        '${foundPct}%',
                                        Icons.check_circle,
                                        AppColors.healthy,
                                        isDark)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildMetricCard(
                                        'Issue Not Found',
                                        '${notFoundPct}%',
                                        Icons.help,
                                        AppColors.warning,
                                        isDark)),
                              ],
                            );
                          })
                        ],
                      )),

                  const SizedBox(width: 12),

                  // Severity distribution pie
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Severity Distribution', style: AppTextStyles.h6),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: PieChart(
                            PieChartData(
                              sections: _buildSeveritySections(tickets),
                              centerSpaceRadius: 28,
                              sectionsSpace: 2,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  if (response == null ||
                                      response.touchedSection == null) return;
                                  final idx = response
                                      .touchedSection!.touchedSectionIndex;
                                  setState(() {
                                    _selectedSeverityFilter =
                                        SeverityLevel.values[idx];
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_selectedSeverityFilter != null)
                          TextButton(
                              onPressed: () => setState(
                                  () => _selectedSeverityFilter = null),
                              child: const Text('Clear severity filter'))
                      ],
                    ),
                  ),
                ],
              );
            }),
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
                    Builder(builder: (_) {
                      final aiTickets = allTickets
                          .where((t) => t.aiConfidence != null)
                          .toList();
                      final avgConfidence = aiTickets.isNotEmpty
                          ? (aiTickets
                                  .map((t) => t.aiConfidence!)
                                  .reduce((a, b) => a + b) /
                              aiTickets.length)
                          : 0.0;
                      final falsePositives = aiTickets
                          .where((t) =>
                              (t.aiConfidence ?? 0) > 0.5 &&
                              t.feedback?.verification ==
                                  IssueVerification.issueNotFound)
                          .length;
                      final fpRate = aiTickets.isNotEmpty
                          ? (falsePositives / aiTickets.length)
                          : 0.0;
                      final confirmed = aiTickets
                          .where((t) =>
                              t.feedback?.verification ==
                              IssueVerification.issueFound)
                          .length;
                      final techConfirm = aiTickets.isNotEmpty
                          ? (confirmed / aiTickets.length)
                          : 0.0;

                      return Column(
                        children: [
                          _buildProgressRow('AI Accuracy', avgConfidence,
                              AppColors.healthy, isDark),
                          const SizedBox(height: 16),
                          _buildProgressRow('False Positive Rate', fpRate,
                              AppColors.warning, isDark),
                          const SizedBox(height: 16),
                          _buildProgressRow('Technician Confirmation',
                              techConfirm, AppColors.info, isDark),
                        ],
                      );
                    }),
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
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor:
                            isDark ? AppColors.darkSurface : AppColors.white,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final label = (idx >= 0 && idx < labels.length)
                                ? labels[idx]
                                : '';
                            return LineTooltipItem(
                                '$label\n${spot.y.toStringAsFixed(0)} min',
                                TextStyle(
                                    color: isDark
                                        ? AppColors.lightText
                                        : Colors.black));
                          }).toList();
                        },
                      ),
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
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= labels.length)
                              return const Text('');

                            if (_selectedPeriod == 'Month') {
                              if (labels.length > 15 &&
                                  idx % 5 != 0 &&
                                  idx != labels.length - 1) {
                                return const Text('');
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
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
                        curveSmoothness: 0.2,
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

  List<PieChartSectionData> _buildSeveritySections(List<TicketModel> tickets) {
    final counts = <SeverityLevel, int>{};
    for (final s in SeverityLevel.values) counts[s] = 0;
    for (final t in tickets) {
      counts[t.severity] = (counts[t.severity] ?? 0) + 1;
    }

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final colors = {
      SeverityLevel.high: AppColors.critical,
      SeverityLevel.medium: AppColors.warning,
      SeverityLevel.low: AppColors.healthy,
    };

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < SeverityLevel.values.length; i++) {
      final sev = SeverityLevel.values[i];
      final cnt = counts[sev] ?? 0;
      final value = cnt.toDouble();
      if (value <= 0) {
        sections
            .add(PieChartSectionData(value: 0, color: colors[sev]!, title: ''));
        continue;
      }
      final pct = total > 0 ? ((value / total) * 100) : 0.0;
      sections.add(PieChartSectionData(
        value: value,
        color: colors[sev]!,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 36,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    return sections;
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
