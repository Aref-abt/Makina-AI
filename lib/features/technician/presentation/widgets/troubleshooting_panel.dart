import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';

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
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: isDark ? AppColors.primaryLightGreen : AppColors.primaryDarkGreen),
              const SizedBox(width: 12),
              Text('Troubleshooting Steps', style: AppTextStyles.h6.copyWith(color: isDark ? AppColors.darkText : AppColors.lightText)),
              const Spacer(),
              Text('${_steps.where((s) => s.isCompleted).length}/${_steps.length}', style: AppTextStyles.labelMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
          const SizedBox(height: 16),

          // Steps list
          if (_steps.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.list_alt, size: 48, color: isDark ? AppColors.darkTextSecondary : AppColors.grey),
                    const SizedBox(height: 12),
                    Text('No troubleshooting steps yet', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    const SizedBox(height: 4),
                    Text('Add steps below to track your progress', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
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
          Text('Add New Step', style: AppTextStyles.labelMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newStepController,
                  decoration: InputDecoration(
                    hintText: 'Enter troubleshooting step...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                  ),
                  onSubmitted: (_) => _addStep(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addStep,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
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
            color: step.isCompleted ? AppColors.healthy.withOpacity(0.1) : (isDark ? AppColors.darkCard : AppColors.lightGrey),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: step.isCompleted ? AppColors.healthy.withOpacity(0.3) : Colors.transparent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.isCompleted ? AppColors.healthy : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text('${index + 1}', style: AppTextStyles.labelMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.grey)),
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
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (step.isAiGenerated) ...[
                          Icon(Icons.psychology, size: 12, color: AppColors.primaryDarkGreen.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('AI Suggested', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDarkGreen.withOpacity(0.7))),
                          const SizedBox(width: 12),
                        ],
                        Text('Added by ${step.createdBy}', style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
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
