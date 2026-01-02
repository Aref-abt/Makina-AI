import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/firestore_service.dart';
import '../../../../shared/data/services/auth_service.dart';

class FeedbackPanel extends ConsumerStatefulWidget {
  final String ticketId;
  final TechnicianFeedback? existingFeedback;

  const FeedbackPanel({
    super.key,
    required this.ticketId,
    this.existingFeedback,
  });

  @override
  ConsumerState<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends ConsumerState<FeedbackPanel> {
  NoiseLevel _noiseLevel = NoiseLevel.none;
  bool _vibrationFelt = false;
  bool _heatFelt = false;
  bool _visibleLeak = false;
  bool _smellDetected = false;
  ActionTaken? _actionTaken;
  Outcome? _outcome;
  IssueVerification? _verification;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingFeedback != null) {
      _noiseLevel = widget.existingFeedback!.noiseLevel;
      _vibrationFelt = widget.existingFeedback!.vibrationFelt;
      _heatFelt = widget.existingFeedback!.heatFelt;
      _visibleLeak = widget.existingFeedback!.visibleLeak;
      _smellDetected = widget.existingFeedback!.smellDetected;
      _actionTaken = widget.existingFeedback!.actionTaken;
      _outcome = widget.existingFeedback!.outcome;
      _verification = widget.existingFeedback!.verification;
      _notesController.text = widget.existingFeedback!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to submit feedback')),
      );
      return;
    }

    if (_verification == null || _actionTaken == null || _outcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedback = TechnicianFeedback(
        id: widget.existingFeedback?.id ?? const Uuid().v4(),
        ticketId: widget.ticketId,
        technicianId: currentUser.id,
        noiseLevel: _noiseLevel,
        vibrationFelt: _vibrationFelt,
        heatFelt: _heatFelt,
        visibleLeak: _visibleLeak,
        smellDetected: _smellDetected,
        actionTaken: _actionTaken!,
        outcome: _outcome!,
        verification: _verification ?? IssueVerification.issueFound,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        submittedAt: DateTime.now(),
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.submitFeedback(feedback);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully'),
            backgroundColor: AppColors.healthy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          Row(
            children: [
              Icon(Icons.feedback_outlined,
                  color: isDark
                      ? AppColors.primaryLightGreen
                      : AppColors.primaryDarkGreen),
              const SizedBox(width: 12),
              Text('Technician Feedback',
                  style: AppTextStyles.h6.copyWith(
                      color:
                          isDark ? AppColors.darkText : AppColors.lightText)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Record your observations to help AI learn and improve',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 20),

          // Observations Section
          Text('Observations',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Noise Level
          _buildSectionLabel('Unusual Noise', isDark),
          const SizedBox(height: 8),
          Row(
            children: NoiseLevel.values
                .map((level) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: level != NoiseLevel.strong ? 8 : 0),
                        child: _buildChoiceChip(
                            level.displayName,
                            _noiseLevel == level,
                            () => setState(() => _noiseLevel = level),
                            isDark),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Yes/No Observations
          _buildToggleRow('Vibration Felt', _vibrationFelt,
              (v) => setState(() => _vibrationFelt = v), isDark),
          _buildToggleRow('Heat Felt', _heatFelt,
              (v) => setState(() => _heatFelt = v), isDark),
          _buildToggleRow('Visible Leak', _visibleLeak,
              (v) => setState(() => _visibleLeak = v), isDark),
          _buildToggleRow('Smell Detected', _smellDetected,
              (v) => setState(() => _smellDetected = v), isDark),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Issue Verification
          Text('Issue Verification',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVerificationButton(
                  IssueVerification.issueFound,
                  'Issue Found',
                  Icons.check_circle_outline,
                  AppColors.healthy,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerificationButton(
                  IssueVerification.issueNotFound,
                  'Issue Not Found',
                  Icons.help_outline,
                  AppColors.warning,
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Taken
          Text('Action Taken',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ActionTaken.values
                .map((action) => _buildActionChip(action, isDark))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Outcome
          Text('Outcome',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Outcome.values
                .map((outcome) => _buildOutcomeChip(outcome, isDark))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Notes
          Text('Additional Notes',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter any additional observations or notes...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
            ),
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitFeedback,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(label,
        style: AppTextStyles.labelMedium.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary));
  }

  Widget _buildChoiceChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDarkGreen
              : (isDark ? AppColors.darkCard : AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color:
                  isSelected ? AppColors.primaryDarkGreen : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkText : AppColors.lightText)),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
      String label, bool value, Function(bool) onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDarkGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationButton(IssueVerification verification, String label,
      IconData icon, Color color, bool isDark) {
    final isSelected = _verification == verification;
    return InkWell(
      onTap: () => setState(() => _verification = verification),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? color
                    : (isDark ? AppColors.darkTextSecondary : AppColors.grey),
                size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? color
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(ActionTaken action, bool isDark) {
    final isSelected = _actionTaken == action;
    return InkWell(
      onTap: () => setState(() => _actionTaken = action),
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDarkGreen
              : (isDark ? AppColors.darkCard : AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
              color:
                  isSelected ? AppColors.primaryDarkGreen : Colors.transparent),
        ),
        child: Text(action.displayName,
            style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkText : AppColors.lightText))),
      ),
    );
  }

  Widget _buildOutcomeChip(Outcome outcome, bool isDark) {
    final isSelected = _outcome == outcome;
    Color color = AppColors.grey;
    if (outcome == Outcome.resolved) color = AppColors.healthy;
    if (outcome == Outcome.partiallyResolved) color = AppColors.warning;
    if (outcome == Outcome.notResolved || outcome == Outcome.needsShutdown)
      color = AppColors.critical;

    return InkWell(
      onTap: () => setState(() => _outcome = outcome),
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(outcome.displayName,
            style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? color
                    : (isDark ? AppColors.darkText : AppColors.lightText))),
      ),
    );
  }
}
