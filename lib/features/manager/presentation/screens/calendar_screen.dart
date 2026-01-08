import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../shared/data/services/export_service.dart';
import 'package:uuid/uuid.dart';
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

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter reminder title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add additional details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today,
                      color: AppColors.primaryDarkGreen),
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  tileColor:
                      (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                          .withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final reminder = CalendarReminder(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  date: _selectedDate,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  createdAt: DateTime.now(),
                  createdBy: 'manager@makina.ai', // In real app, get from auth
                );

                MockDataService().addReminder(reminder);
                Navigator.pop(context);
                setState(() {}); // Refresh the calendar

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Reminder added for ${_formatDate(_selectedDate)}'),
                    backgroundColor: AppColors.healthy,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showExportOptions(
      List<TicketModel> tickets, List<CalendarReminder> reminders) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export PDF'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _exportPDF(tickets);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Export CSV (copied to clipboard)'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _exportCSV(tickets);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _exportCSV(List<TicketModel> tickets) async {
    final csv = ExportService.exportTicketsToCSV(tickets);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV content copied to clipboard')));
  }

  Future<void> _exportPDF(List<TicketModel> tickets) async {
    final headers = ['ID', 'Title', 'Machine', 'Status', 'Severity', 'Created'];
    final rows = tickets
        .map((t) => [
              t.id,
              t.title,
              t.machineName,
              t.status.displayName,
              t.severity.displayName,
              _formatDate(t.createdAt)
            ])
        .toList();

    await ExportService.generatePDFReport(
        title: 'Tickets Report',
        headers: headers,
        rows: rows,
        tickets: tickets,
        users: null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets =
        MockDataService().tickets.where((t) => t.scheduledAt != null).toList();
    final reminders = MockDataService().reminders;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Calendar'), actions: [
        IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportOptions(tickets, reminders)),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppColors.primaryDarkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                    IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() => _focusedMonth =
                            DateTime(
                                _focusedMonth.year, _focusedMonth.month - 1))),
                    Text(_getMonthYear(_focusedMonth), style: AppTextStyles.h5),
                    IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => _focusedMonth =
                            DateTime(
                                _focusedMonth.year, _focusedMonth.month + 1))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => Expanded(
                            child: Center(
                                child: Text(day,
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary)))))
                        .toList()),
                const SizedBox(height: 8),
                _buildCalendarGrid(isDark, tickets, reminders),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scheduled tickets and reminders for selected date
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled for ${_formatDate(_selectedDate)}',
                      style: AppTextStyles.h6),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildScheduledItems(
                      tickets
                          .where(
                              (t) => _isSameDay(t.scheduledAt!, _selectedDate))
                          .toList(),
                      reminders
                          .where((r) => _isSameDay(r.date, _selectedDate))
                          .toList(),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark, List<TicketModel> tickets,
      List<CalendarReminder> reminders) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final days = <Widget>[];

    for (int i = 0; i < startWeekday; i++) days.add(const SizedBox());
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final ticketsOnDate = tickets
          .where(
              (t) => t.scheduledAt != null && _isSameDay(t.scheduledAt!, date))
          .toList();
      final hasTickets = ticketsOnDate.isNotEmpty;
      final hasReminders = reminders.any((r) => _isSameDay(r.date, date));
      final hasCritical =
          ticketsOnDate.any((t) => t.severity == SeverityLevel.high);

      days.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryDarkGreen
                : (isToday
                    ? AppColors.primaryDarkGreen.withOpacity(0.1)
                    : null),
            borderRadius: BorderRadius.circular(8),
            border: isToday && !isSelected
                ? Border.all(color: AppColors.primaryDarkGreen)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$day',
                  style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal)),
              if (hasTickets || hasReminders)
                Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // show up to 3 ticket chips with severity color and technician initials
                      if (hasTickets)
                        ...ticketsOnDate.take(3).map((t) {
                          final initials = (t.assigneeName ?? t.machineName)
                              .split(' ')
                              .where((s) => s.isNotEmpty)
                              .map((s) => s[0])
                              .take(2)
                              .join();
                          return GestureDetector(
                            onTap: () => context.go('/manager/tickets/${t.id}'),
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: t.severity.color,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 9)),
                            ),
                          );
                        }).toList(),
                      if (hasReminders)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        children: days);
  }

  Widget _buildScheduledItems(List<TicketModel> tickets,
      List<CalendarReminder> reminders, bool isDark) {
    if (tickets.isEmpty && reminders.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.event_available,
            size: 48,
            color: isDark ? AppColors.darkTextSecondary : AppColors.grey),
        const SizedBox(height: 12),
        Text('No scheduled items',
            style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
        const SizedBox(height: 8),
        Text('Tap + to add a reminder',
            style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
      ]));
    }

    return ListView(
      children: [
        // Reminders Section
        if (reminders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.event_note,
                    size: 20, color: AppColors.primaryLightGreen),
                const SizedBox(width: 8),
                Text('Reminders',
                    style: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...reminders.map((reminder) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check_circle_outline,
                        color: AppColors.primaryLightGreen, size: 24),
                  ),
                  title: Text(reminder.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: reminder.notes != null
                      ? Text(reminder.notes!,
                          maxLines: 2, overflow: TextOverflow.ellipsis)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.critical,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Reminder'),
                          content: Text('Delete "${reminder.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                MockDataService().deleteReminder(reminder.id);
                                Navigator.pop(context);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Reminder deleted')),
                                );
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.critical),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )),
          if (tickets.isNotEmpty) const SizedBox(height: 16),
        ],

        // Tickets Section
        if (tickets.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.build, size: 20, color: AppColors.info),
                const SizedBox(width: 8),
                Text('Maintenance Tickets',
                    style: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...tickets.map((ticket) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => context.go('/manager/tickets/${ticket.id}'),
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                        color: ticket.severity.color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  title: Text(ticket.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(ticket.machineName),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: ticket.severity.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(ticket.severity.displayName,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: ticket.severity.color)),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  String _getMonthYear(DateTime date) => '${[
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][date.month - 1]} ${date.year}';
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
