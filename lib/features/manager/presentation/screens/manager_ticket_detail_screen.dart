import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../technician/presentation/widgets/machine_3d_viewer.dart';
import '../../../technician/presentation/widgets/ai_insights_panel.dart';

class ManagerTicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const ManagerTicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticket =
        MockDataService().tickets.firstWhere((t) => t.id == ticketId);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/manager/tickets')),
          title:
              Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          bottom: TabBar(
            labelColor: isDark
                ? AppColors.primaryLightGreen
                : AppColors.primaryDarkGreen,
            unselectedLabelColor:
                isDark ? AppColors.darkTextSecondary : AppColors.grey,
            indicatorColor: isDark
                ? AppColors.primaryLightGreen
                : AppColors.primaryDarkGreen,
            tabs: const [
              Tab(text: 'Visual'),
              Tab(text: 'AI Insights'),
              Tab(text: 'Details')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Machine3DViewer(
                machineId: ticket.machineId,
                highlightedComponentId: ticket.componentId,
                ticketId: ticket.id),
            AIInsightsPanel(ticketId: ticketId),
            _buildDetailsTab(ticket, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(TicketModel ticket, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              'Status', ticket.status.displayName, ticket.status.color, isDark),
          _buildInfoRow('Severity', ticket.severity.displayName,
              ticket.severity.color, isDark),
          _buildInfoRow('Machine', ticket.machineName, null, isDark),
          if (ticket.componentName != null)
            _buildInfoRow('Component', ticket.componentName!, null, isDark),
          if (ticket.assigneeName != null)
            _buildInfoRow('Assignee', ticket.assigneeName!,
                AppColors.primaryDarkGreen, isDark),
          _buildInfoRow(
              'Skill Required', ticket.requiredSkill.displayName, null, isDark),
          const SizedBox(height: 20),
          if (ticket.estimatedCost != null) ...[
            Text('Cost Estimate', style: AppTextStyles.h6),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                  color: AppColors.critical.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: AppColors.critical),
                  const SizedBox(width: 8),
                  Text('\$${ticket.estimatedCost!.toStringAsFixed(0)}',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.critical)),
                  const Spacer(),
                  if (ticket.estimatedDowntimeMinutes != null)
                    Text(
                        '${ticket.estimatedDowntimeMinutes!.toStringAsFixed(0)} min downtime',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.critical)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color? valueColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label:',
              style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(width: 12),
          if (valueColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(value,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: valueColor, fontWeight: FontWeight.w600)),
            )
          else
            Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
