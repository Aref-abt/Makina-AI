import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final bool isListView;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(
          color: ticket.severity == SeverityLevel.high
              ? AppColors.critical.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: ticket.severity == SeverityLevel.high ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            gradient: ticket.severity == SeverityLevel.high
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.critical.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with severity and status
              Row(
                children: [
                  _buildSeverityBadge(ticket.severity),
                  const Spacer(),
                  _buildStatusBadge(ticket.status, isDark),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                ticket.title,
                style: AppTextStyles.h6.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Machine info
              Row(
                children: [
                  Icon(
                    Icons.precision_manufacturing_outlined,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ticket.machineName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (ticket.componentName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket.componentName!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Skill required
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSkillIcon(ticket.requiredSkill),
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.requiredSkill.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(ticket.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Assignee (if assigned)
              if (ticket.assigneeName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.2),
                      child: Text(
                        ticket.assigneeName!.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.assigneeName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (ticket.status == TicketStatus.inProgress) ...[
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLightGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Working',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryLightGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // AI confidence (if available)
              if (ticket.aiConfidence != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 14,
                      color: _getConfidenceColor(ticket.aiConfidence!),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Confidence: ${(ticket.aiConfidence! * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getConfidenceColor(ticket.aiConfidence!),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(SeverityLevel severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: severity.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (severity == SeverityLevel.high)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: severity.color,
              ),
            ),
          Text(
            severity.displayName,
            style: AppTextStyles.labelSmall.copyWith(
              color: severity.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.labelSmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getSkillIcon(ExpertiseType skill) {
    switch (skill) {
      case ExpertiseType.mechanical:
        return Icons.build_outlined;
      case ExpertiseType.electrical:
        return Icons.electrical_services_outlined;
      case ExpertiseType.automation:
        return Icons.smart_toy_outlined;
      case ExpertiseType.plumbing:
        return Icons.water_drop_outlined;
      case ExpertiseType.hvac:
        return Icons.air_outlined;
      case ExpertiseType.general:
        return Icons.handyman_outlined;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.healthy;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.critical;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
