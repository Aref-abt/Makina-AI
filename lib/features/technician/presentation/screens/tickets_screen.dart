import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/services/auth_service.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_kanban_column.dart';

enum TicketViewMode { board, list }

final ticketViewModeProvider =
    StateProvider<TicketViewMode>((ref) => TicketViewMode.board);
final ticketsProvider = StateProvider<List<TicketModel>>((ref) {
  return MockDataService().tickets;
});

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewMode = ref.watch(ticketViewModeProvider);
    final tickets = ref.watch(ticketsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;

    // Filter tickets for technician (exclude completed older than 24h for cleaner view)
    final activeTickets = tickets.where((t) {
      if (t.status == TicketStatus.done) {
        return t.resolvedAt != null &&
            DateTime.now().difference(t.resolvedAt!).inHours < 24;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tickets'),
            if (currentUser != null)
              Text(
                'Welcome, ${currentUser.fullName.split(' ').first}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/technician/tickets/create'),
          ),
          // View toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggle(
                  icon: Icons.view_column_outlined,
                  isSelected: viewMode == TicketViewMode.board,
                  onTap: () => ref.read(ticketViewModeProvider.notifier).state =
                      TicketViewMode.board,
                  isDark: isDark,
                ),
                _buildViewToggle(
                  icon: Icons.view_list_outlined,
                  isSelected: viewMode == TicketViewMode.list,
                  onTap: () => ref.read(ticketViewModeProvider.notifier).state =
                      TicketViewMode.list,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh tickets
              MockDataService().initialize();
              ref.read(ticketsProvider.notifier).state =
                  MockDataService().tickets;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          _buildStatsBar(activeTickets, isDark),

          // Main content
          Expanded(
            child: viewMode == TicketViewMode.board
                ? _buildBoardView(activeTickets, isDark, isTablet)
                : _buildListView(activeTickets, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingS),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLightGreen.withOpacity(0.2)
                  : AppColors.primaryDarkGreen.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLightGreen
                  : AppColors.primaryDarkGreen)
              : (isDark ? AppColors.darkTextSecondary : AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildStatsBar(List<TicketModel> tickets, bool isDark) {
    final todoCount =
        tickets.where((t) => t.status == TicketStatus.toDo).length;
    final inProgressCount =
        tickets.where((t) => t.status == TicketStatus.inProgress).length;
    final doneCount =
        tickets.where((t) => t.status == TicketStatus.done).length;
    final criticalCount = tickets
        .where((t) =>
            t.severity == SeverityLevel.high && t.status != TicketStatus.done)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatChip('To Do', todoCount, AppColors.statusToDo, isDark),
            const SizedBox(width: 12),
            _buildStatChip('In Progress', inProgressCount,
                AppColors.statusInProgress, isDark),
            const SizedBox(width: 12),
            _buildStatChip('Done', doneCount, AppColors.statusDone, isDark),
            const SizedBox(width: 12),
            _buildStatChip(
                'Critical', criticalCount, AppColors.critical, isDark,
                isCritical: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color, bool isDark,
      {bool isCritical = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: isCritical && count > 0
            ? color.withOpacity(0.15)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isCritical && count > 0
              ? color
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: AppTextStyles.labelMedium.copyWith(
              color: isCritical && count > 0
                  ? color
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardView(
      List<TicketModel> tickets, bool isDark, bool isTablet) {
    final todoTickets =
        tickets.where((t) => t.status == TicketStatus.toDo).toList();
    final inProgressTickets =
        tickets.where((t) => t.status == TicketStatus.inProgress).toList();
    final doneTickets =
        tickets.where((t) => t.status == TicketStatus.done).toList();

    if (isTablet) {
      // Horizontal layout for tablets
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TicketKanbanColumn(
                title: 'To Do',
                status: TicketStatus.toDo,
                tickets: todoTickets,
                color: AppColors.statusToDo,
                onTicketTap: (ticket) =>
                    context.go('/technician/tickets/${ticket.id}'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TicketKanbanColumn(
                title: 'In Progress',
                status: TicketStatus.inProgress,
                tickets: inProgressTickets,
                color: AppColors.statusInProgress,
                onTicketTap: (ticket) =>
                    context.go('/technician/tickets/${ticket.id}'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TicketKanbanColumn(
                title: 'Done',
                status: TicketStatus.done,
                tickets: doneTickets,
                color: AppColors.statusDone,
                onTicketTap: (ticket) =>
                    context.go('/technician/tickets/${ticket.id}'),
              ),
            ),
          ],
        ),
      );
    }

    // Horizontal scrollable for phones
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: TicketKanbanColumn(
              title: 'To Do',
              status: TicketStatus.toDo,
              tickets: todoTickets,
              color: AppColors.statusToDo,
              onTicketTap: (ticket) =>
                  context.go('/technician/tickets/${ticket.id}'),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: TicketKanbanColumn(
              title: 'In Progress',
              status: TicketStatus.inProgress,
              tickets: inProgressTickets,
              color: AppColors.statusInProgress,
              onTicketTap: (ticket) =>
                  context.go('/technician/tickets/${ticket.id}'),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: TicketKanbanColumn(
              title: 'Done',
              status: TicketStatus.done,
              tickets: doneTickets,
              color: AppColors.statusDone,
              onTicketTap: (ticket) =>
                  context.go('/technician/tickets/${ticket.id}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<TicketModel> tickets, bool isDark) {
    // Sort by severity (high first) then by date
    final sortedTickets = List<TicketModel>.from(tickets)
      ..sort((a, b) {
        if (a.status != b.status) {
          return a.status.index.compareTo(b.status.index);
        }
        if (a.severity != b.severity) {
          return a.severity.index.compareTo(b.severity.index);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: sortedTickets.length,
      itemBuilder: (context, index) {
        final ticket = sortedTickets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: TicketCard(
            ticket: ticket,
            onTap: () => context.go('/technician/tickets/${ticket.id}'),
            isListView: true,
          ),
        );
      },
    );
  }
}
