import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import 'ticket_card.dart';

class TicketKanbanColumn extends StatelessWidget {
  final String title;
  final TicketStatus status;
  final List<TicketModel> tickets;
  final Color color;
  final Function(TicketModel) onTicketTap;

  const TicketKanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tickets,
    required this.color,
    required this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.5)
            : AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusL),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tickets list
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getEmptyIcon(status),
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary.withOpacity(0.5)
                              : AppColors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getEmptyMessage(status),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingM,
                        ),
                        child: TicketCard(
                          ticket: ticket,
                          onTap: () => onTicketTap(ticket),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.toDo:
        return Icons.inbox_outlined;
      case TicketStatus.inProgress:
        return Icons.hourglass_empty;
      case TicketStatus.done:
        return Icons.check_circle_outline;
    }
  }

  String _getEmptyMessage(TicketStatus status) {
    switch (status) {
      case TicketStatus.toDo:
        return 'No pending tickets';
      case TicketStatus.inProgress:
        return 'No tickets in progress';
      case TicketStatus.done:
        return 'No completed tickets';
    }
  }
}
