import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TroubleshootingPanel extends StatefulWidget {
  final String ticketId;
  final List<TroubleshootingStep> steps;

  const TroubleshootingPanel({
    super.key,
    required this.ticketId,
    required this.steps,
  });

  @override
  State<TroubleshootingPanel> createState() => _TroubleshootingPanelState();
}

class _TroubleshootingPanelState extends State<TroubleshootingPanel> {
  late List<TroubleshootingStep> _steps;
  final TextEditingController _newStepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _steps = List.from(widget.steps);
  }

  @override
  void dispose() {
    _newStepController.dispose();
    super.dispose();
  }

  void _addStep() {
    if (_newStepController.text.trim().isEmpty) return;

    setState(() {
      _steps.add(TroubleshootingStep(
        id: 'step_${DateTime.now().millisecondsSinceEpoch}',
        ticketId: widget.ticketId,
        description: _newStepController.text.trim(),
        createdBy: 'Current User',
        isAiGenerated: false,
      ));
      _newStepController.clear();
    });
  }

  void _toggleStep(int index) {
    setState(() {
      final step = _steps[index];
      _steps[index] = TroubleshootingStep(
        id: step.id,
        ticketId: step.ticketId,
        description: step.description,
        isCompleted: !step.isCompleted,
        createdBy: step.createdBy,
        createdAt: step.createdAt,
        isAiGenerated: step.isAiGenerated,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Wrap header so it flows on narrow screens and the AI button doesn't overflow
          LayoutBuilder(builder: (ctx, constraints) {
            final isNarrow =
                constraints.maxWidth <= AppDimensions.mobileBreakpoint;
            return Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.checklist,
                      color: isDark
                          ? AppColors.primaryLightGreen
                          : AppColors.primaryDarkGreen),
                  const SizedBox(width: 12),
                  Text('Troubleshooting Steps',
                      style: AppTextStyles.h6.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                      '${_steps.where((s) => s.isCompleted).length}/${_steps.length}',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Suggest'),
                    onPressed: _insertAiSuggestions,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8)),
                  ),
                ]),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Steps list
          if (_steps.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.list_alt,
                        size: 48,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey),
                    const SizedBox(height: 12),
                    Text('No troubleshooting steps yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)),
                    const SizedBox(height: 4),
                    Text('Add steps below to track your progress',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_steps.length, (index) {
              final step = _steps[index];
              return _buildStepItem(step, index, isDark);
            }),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Add new step
          Text('Add New Step',
              style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newStepController,
                  decoration: InputDecoration(
                    hintText: 'Enter troubleshooting step...',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM)),
                  ),
                  onSubmitted: (_) => _addStep(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addStep,
                style:
                    ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _insertAiSuggestions() async {
    // Fetch AI insight for this ticket
    try {
      final insight = MockDataService().getAIInsight(widget.ticketId);
      final raw = insight.potentialCause.isNotEmpty
          ? insight.potentialCause
          : insight.whatIsHappening;

      // Split into sentences and take the first 3 actionable items
      final sentences = raw
          .split(RegExp(r'[\.\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final suggestions = sentences.take(3).toList();

      final inserted = <TroubleshootingStep>[];
      for (final s in suggestions) {
        final step = TroubleshootingStep(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${_steps.length}',
          ticketId: widget.ticketId,
          description:
              s[0].toUpperCase() + (s.length > 1 ? s.substring(1) : ''),
          createdBy: 'AI Assistant',
          isAiGenerated: true,
        );
        inserted.add(step);
      }

      try {
        MockDataService().addTroubleshootingSteps(widget.ticketId, inserted);
      } catch (_) {}

      setState(() {
        _steps.addAll(inserted);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserted AI suggested steps')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI suggestions unavailable')));
    }
  }

  Widget _buildStepItem(TroubleshootingStep step, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleStep(index),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: step.isCompleted
                ? AppColors.healthy.withOpacity(0.1)
                : (isDark ? AppColors.darkCard : AppColors.lightGrey),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
                color: step.isCompleted
                    ? AppColors.healthy.withOpacity(0.3)
                    : Colors.transparent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? AppColors.healthy
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text('${index + 1}',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        decoration: step.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (step.isAiGenerated) ...[
                          Icon(Icons.psychology,
                              size: 12,
                              color:
                                  AppColors.primaryDarkGreen.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('AI Suggested',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryDarkGreen
                                      .withOpacity(0.7))),
                          const SizedBox(width: 12),
                        ],
                        Text('Added by ${step.createdBy}',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
