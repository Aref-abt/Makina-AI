import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = MockDataService().tickets.where((t) => t.scheduledAt != null).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // Calendar Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
                    Text(_getMonthYear(_focusedMonth), style: AppTextStyles.h5),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => Expanded(child: Center(child: Text(day, style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))))).toList()),
                const SizedBox(height: 8),
                _buildCalendarGrid(isDark, tickets),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scheduled tickets for selected date
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled for ${_formatDate(_selectedDate)}', style: AppTextStyles.h6),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildScheduledTickets(tickets.where((t) => _isSameDay(t.scheduledAt!, _selectedDate)).toList(), isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark, List<TicketModel> tickets) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final days = <Widget>[];

    for (int i = 0; i < startWeekday; i++) days.add(const SizedBox());
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasTickets = tickets.any((t) => t.scheduledAt != null && _isSameDay(t.scheduledAt!, date));
      final hasCritical = tickets.any((t) => t.scheduledAt != null && _isSameDay(t.scheduledAt!, date) && t.severity == SeverityLevel.high);

      days.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkGreen : (isToday ? AppColors.primaryDarkGreen.withOpacity(0.1) : null),
            borderRadius: BorderRadius.circular(8),
            border: isToday && !isSelected ? Border.all(color: AppColors.primaryDarkGreen) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$day', style: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText), fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
              if (hasTickets) Positioned(bottom: 4, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: hasCritical ? AppColors.critical : AppColors.info, shape: BoxShape.circle))),
            ],
          ),
        ),
      ));
    }

    return GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1, children: days);
  }

  Widget _buildScheduledTickets(List<TicketModel> tickets, bool isDark) {
    if (tickets.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.event_available, size: 48, color: isDark ? AppColors.darkTextSecondary : AppColors.grey),
        const SizedBox(height: 12),
        Text('No scheduled tickets', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ]));
    }

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(color: ticket.severity.color, borderRadius: BorderRadius.circular(2)),
            ),
            title: Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(ticket.machineName),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: ticket.severity.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(ticket.severity.displayName, style: AppTextStyles.labelSmall.copyWith(color: ticket.severity.color)),
            ),
          ),
        );
      },
    );
  }

  String _getMonthYear(DateTime date) => '${['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][date.month - 1]} ${date.year}';
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
