import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class AIInsightsPanel extends StatelessWidget {
  final String ticketId;

  const AIInsightsPanel({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mockData = MockDataService();
    final insight = mockData.getAIInsight(ticketId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDarkGreen.withOpacity(0.1),
                  AppColors.primaryLightGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: AppColors.primaryDarkGreen.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: AppColors.primaryDarkGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Analysis', style: AppTextStyles.h6),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Confidence: ', style: AppTextStyles.bodySmall),
                          _buildConfidenceBadge(insight.confidenceLevel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // What is happening
          _buildInsightSection(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
            title: 'What is Happening',
            content: insight.whatIsHappening,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Why it matters
          _buildInsightSection(
            icon: Icons.priority_high,
            iconColor: AppColors.critical,
            title: 'Why It Matters',
            content: insight.whyItMatters,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Potential cause
          _buildInsightSection(
            icon: Icons.search,
            iconColor: AppColors.info,
            title: 'Potential Cause',
            content: insight.potentialCause,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Contributing signals
          Text('Contributing Sensor Signals', style: AppTextStyles.h6.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 12),
          ...insight.contributingSignals.map((signal) => _buildSignalCard(signal, isDark)),
          const SizedBox(height: 20),

          // Similar past cases
          if (insight.similarPastCases.isNotEmpty) ...[
            Text('Similar Past Cases', style: AppTextStyles.h6.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText)),
            const SizedBox(height: 12),
            ...insight.similarPastCases.map((caseText) => _buildPastCaseCard(caseText, isDark)),
          ],

          // Uncertainty note
          if (insight.uncertaintyNote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Note', style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(insight.uncertaintyNote!, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    Color color;
    String label;
    if (confidence >= 0.8) {
      color = AppColors.healthy;
      label = 'High';
    } else if (confidence >= 0.6) {
      color = AppColors.warning;
      label = 'Medium';
    } else {
      color = AppColors.critical;
      label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label (${(confidence * 100).toStringAsFixed(0)}%)', style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInsightSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.labelLarge.copyWith(color: iconColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSignalCard(SensorSignal signal, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: signal.isAbnormal ? AppColors.critical.withOpacity(0.5) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(signal.type, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (signal.isAbnormal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.critical.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber, size: 14, color: AppColors.critical),
                      const SizedBox(width: 4),
                      Text('Abnormal', style: AppTextStyles.labelSmall.copyWith(color: AppColors.critical)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current', style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text('${signal.currentValue.toStringAsFixed(1)} ${signal.unit}', style: AppTextStyles.h5.copyWith(color: signal.isAbnormal ? AppColors.critical : AppColors.primaryDarkGreen)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Normal Range', style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text('${signal.normalMin.toStringAsFixed(0)} - ${signal.normalMax.toStringAsFixed(0)} ${signal.unit}', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deviation', style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text('+${signal.deviation.toStringAsFixed(1)}%', style: AppTextStyles.bodyMedium.copyWith(color: signal.isAbnormal ? AppColors.critical : AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastCaseCard(String caseText, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(caseText, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText))),
        ],
      ),
    );
  }
}
