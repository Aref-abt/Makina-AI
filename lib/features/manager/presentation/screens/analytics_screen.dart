import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export'),
              onPressed: () {}),
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
              child: SizedBox(
                height: 200,
                child: CustomPaint(painter: _BarChartPainter(isDark: isDark)),
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
              child: SizedBox(
                height: 180,
                child: CustomPaint(painter: _LineChartPainter(isDark: isDark)),
              ),
            ),
          ],
        ),
      ),
    );
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

class _BarChartPainter extends CustomPainter {
  final bool isDark;
  _BarChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = size.width / 14;
    final values = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.5];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < values.length; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final height = values[i] * (size.height - 40);
      paint.color = i == 3 ? AppColors.critical : AppColors.primaryDarkGreen;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, size.height - 30 - height, barWidth, height),
              const Radius.circular(4)),
          paint);

      final textPainter = TextPainter(
          text: TextSpan(
              text: labels[i],
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 10)),
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LineChartPainter extends CustomPainter {
  final bool isDark;
  _LineChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDarkGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final values = [0.6, 0.5, 0.7, 0.4, 0.3, 0.5, 0.4];

    for (int i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - 30 - values[i] * (size.height - 50);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Draw dots
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - 30 - values[i] * (size.height - 50);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
