import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/auth_service.dart';
import '../widgets/machine_3d_viewer.dart';
import '../widgets/ai_insights_panel.dart';
import '../widgets/troubleshooting_panel.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/asme_guidelines_panel.dart';
import '../screens/tickets_screen.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockDataService _mockData = MockDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TicketModel? get ticket {
    try {
      return _mockData.tickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;
    final currentUser = ref.watch(currentUserProvider);
    final currentTicket = ticket;

    if (currentTicket == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/technician/tickets'),
          ),
          title: const Text('Ticket Not Found'),
        ),
        body: const Center(
          child: Text('This ticket could not be found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: isTablet ? 280 : 240,
              pinned: true,
              floating: false,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withOpacity(0.8)
                        : AppColors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    size: 20,
                  ),
                ),
                onPressed: () => context.go('/technician/tickets'),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withOpacity(0.8)
                          : AppColors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: currentTicket.severity == SeverityLevel.high
                          ? [
                              AppColors.critical.withOpacity(0.8),
                              AppColors.critical.withOpacity(0.6),
                            ]
                          : currentTicket.severity == SeverityLevel.medium
                              ? [
                                  AppColors.warning.withOpacity(0.8),
                                  AppColors.warning.withOpacity(0.6),
                                ]
                              : [
                                  AppColors.primaryDarkGreen,
                                  AppColors.primaryLightGreen,
                                ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Severity badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (currentTicket.severity == SeverityLevel.high)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    Text(
                                      '${currentTicket.severity.displayName} Priority',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentTicket.status.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Title
                          Text(
                            currentTicket.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Machine info
                          Row(
                            children: [
                              const Icon(
                                Icons.precision_manufacturing,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentTicket.machineName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              if (currentTicket.componentName != null) ...[
                                const Text(
                                  ' • ',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const Icon(
                                  Icons.settings,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentTicket.componentName!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: isDark
                      ? AppColors.primaryLightGreen
                      : AppColors.primaryDarkGreen,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.grey,
                  indicatorColor: isDark
                      ? AppColors.primaryLightGreen
                      : AppColors.primaryDarkGreen,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Visual'),
                    Tab(text: 'AI Insights'),
                    Tab(text: 'Actions'),
                    Tab(text: 'ASME'),
                  ],
                ),
                isDark: isDark,
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Visual Tab - 3D Machine View
            Machine3DViewer(
              machineId: currentTicket.machineId,
              highlightedComponentId: currentTicket.componentId,
            ),

            // AI Insights Tab
            AIInsightsPanel(ticketId: widget.ticketId),

            // Actions Tab - Troubleshooting & Feedback
            _buildActionsTab(currentTicket, currentUser, isDark),

            // ASME Tab
            ASMEGuidelinesPanel(
              componentType: currentTicket.componentName ?? 'Motor',
              failureMode: 'Overheating',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(currentTicket, currentUser, isDark),
    );
  }

  Widget _buildActionsTab(TicketModel ticket, UserModel? currentUser, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Troubleshooting Section
          TroubleshootingPanel(
            ticketId: widget.ticketId,
            steps: ticket.troubleshootingSteps,
          ),
          const SizedBox(height: 24),

          // Feedback Section
          if (ticket.status == TicketStatus.inProgress ||
              ticket.assigneeId == currentUser?.id)
            FeedbackPanel(
              ticketId: widget.ticketId,
              existingFeedback: ticket.feedback,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(TicketModel ticket, UserModel? currentUser, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingM,
        AppDimensions.paddingL,
        MediaQuery.of(context).padding.bottom + AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (ticket.status == TicketStatus.toDo) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _respondToTicket(ticket, currentUser),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Respond'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ] else if (ticket.status == TicketStatus.inProgress) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAssignDialog(),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Reassign'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _resolveTicket(ticket),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Resolve'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.healthy,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.healthy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.healthy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Resolved',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.healthy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _respondToTicket(TicketModel ticket, UserModel? currentUser) {
    if (currentUser == null) return;

    _mockData.updateTicketStatus(ticket.id, TicketStatus.inProgress);
    _mockData.assignTicket(ticket.id, currentUser.id);
    
    ref.read(ticketsProvider.notifier).state = List.from(_mockData.tickets);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are now responding to this ticket'),
        backgroundColor: AppColors.primaryDarkGreen,
      ),
    );
    setState(() {});
  }

  void _resolveTicket(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Ticket'),
        content: const Text('Are you sure you want to mark this ticket as resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _mockData.updateTicketStatus(ticket.id, TicketStatus.done);
              ref.read(ticketsProvider.notifier).state = List.from(_mockData.tickets);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket resolved successfully'),
                  backgroundColor: AppColors.healthy,
                ),
              );
              setState(() {});
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog() {
    final technicians = _mockData.users
        .where((u) => u.role == UserRole.technician && u.isActive)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Assign to Technician',
                  style: AppTextStyles.h5,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: technicians.length,
                  itemBuilder: (context, index) {
                    final tech = technicians[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryDarkGreen.withOpacity(0.2),
                        child: Text(
                          tech.fullName.substring(0, 1),
                          style: const TextStyle(
                            color: AppColors.primaryDarkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(tech.fullName),
                      subtitle: Text(
                        tech.expertise.map((e) => e.displayName).join(', '),
                        style: AppTextStyles.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _mockData.assignTicket(widget.ticketId, tech.id);
                        ref.read(ticketsProvider.notifier).state = 
                            List.from(_mockData.tickets);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Assigned to ${tech.fullName}'),
                            backgroundColor: AppColors.primaryDarkGreen,
                          ),
                        );
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Ticket'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Print Report'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this.tabBar, {required this.isDark});

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
