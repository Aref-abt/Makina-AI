// Manager Tickets Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../technician/presentation/widgets/ticket_card.dart';

class ManagerTicketsScreen extends ConsumerWidget {
  const ManagerTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = MockDataService().tickets;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('All Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/manager/tickets/create'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: tickets.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TicketCard(
              ticket: tickets[index],
              onTap: () => context.go('/manager/tickets/${tickets[index].id}'),
              isListView: true),
        ),
      ),
    );
  }
}
