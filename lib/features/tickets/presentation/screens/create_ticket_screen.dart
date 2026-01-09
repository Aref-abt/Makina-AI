import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/data/models/models.dart';
import '../../../technician/presentation/screens/tickets_screen.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  SeverityLevel _severity = SeverityLevel.medium;
  String? _selectedMachineId;
  int? _storyPoints = 3;

  @override
  void initState() {
    super.initState();
    final machines = MockDataService().machines;
    if (machines.isNotEmpty) _selectedMachineId = machines.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final machines = MockDataService().machines;
    if (machines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No machines available. Add a machine first.')),
      );
      return;
    }
    final machine = machines.firstWhere((m) => m.id == _selectedMachineId,
        orElse: () => machines.first);

    final ticket = MockDataService().createTicket(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      machineId: machine.id,
      machineName: machine.name,
      severity: _severity,
      storyPoints: _storyPoints,
    );

    // Update technician tickets provider if present (some screens use it)
    try {
      ref.read(ticketViewModeProvider.notifier);
      // if import exists, update provider state
      ref.read(ticketsProvider.notifier).state = MockDataService().tickets;
    } catch (_) {}

    // Navigate to the created ticket detail (manager/technician routes differ)
    // Try to infer current route and navigate accordingly
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/manager')) {
      context.go('/manager/tickets/${ticket.id}');
    } else {
      context.go('/technician/tickets/${ticket.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final machines = MockDataService().machines;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _storyPoints,
                decoration: const InputDecoration(labelText: 'Story Points'),
                items: [1, 2, 3, 5, 8, 13]
                    .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                    .toList(),
                onChanged: (v) => setState(() => _storyPoints = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMachineId,
                items: machines
                    .map((m) =>
                        DropdownMenuItem(value: m.id, child: Text(m.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMachineId = v),
                decoration: const InputDecoration(labelText: 'Machine'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SeverityLevel>(
                value: _severity,
                items: SeverityLevel.values
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.displayName)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _severity = v ?? SeverityLevel.medium),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create Ticket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
