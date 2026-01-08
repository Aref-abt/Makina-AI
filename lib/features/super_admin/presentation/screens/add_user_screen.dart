import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';
import '../../../../shared/providers/user_provider.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  final String? userId;
  const AddUserScreen({super.key, this.userId});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.technician;
  String? _selectedFloor;
  final Set<ExpertiseType> _selectedExpertise = {};
  final Set<String> _selectedMachines = {};
  bool _isLoading = false;

  final List<String> _floors = ['Floor 1', 'Floor 2', 'Floor 3'];

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      try {
        // Defensive lookup: avoid throwing during first build and handle unexpected data shapes
        final matches = MockDataService()
            .users
            .where((u) => u.id == widget.userId)
            .toList();
        if (matches.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not found')),
              );
              Navigator.of(context).pop();
            }
          });
          return;
        }

        final user = matches.first;

        // Safely assign fields, validating types where necessary
        _nameController.text = user.fullName;
        _employeeIdController.text = user.employeeId;
        _emailController.text = user.email;
        _selectedRole = user.role;
        _selectedFloor = user.assignedFloor;
        // Ensure initial dropdown value exists in our floors list; if not, clear it
        if (_selectedFloor != null && !_floors.contains(_selectedFloor)) {
          _selectedFloor = null;
        }

        // Ensure expertise list contains only valid ExpertiseType items
        final items = <ExpertiseType>[];
        for (final e in user.expertise) {
          if (e is ExpertiseType) {
            items.add(e);
          } else if (e is String) {
            final matched = ExpertiseType.values.firstWhere(
                (ex) => ex.name == e,
                orElse: () => ExpertiseType.general);
            items.add(matched);
          }
        }
        _selectedExpertise.addAll(items);

        _selectedMachines.addAll(user.assignedMachineIds);
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to open user for edit: $e')),
            );
            Navigator.of(context).pop();
          }
        });
        return;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.userId != null;
    final machines = MockDataService().machines;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: Text(isEditing ? 'Edit User' : 'Add New User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              Text('Basic Information', style: AppTextStyles.h6),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(
                      labelText: 'Employee ID', prefixIcon: Icon(Icons.badge)),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 16),
              if (!isEditing)
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 24),

              // Role Selection
              Text('Role', style: AppTextStyles.h6),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildRoleChip(UserRole.technician, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRoleChip(UserRole.manager, isDark)),
                ],
              ),
              const SizedBox(height: 24),

              // Floor Assignment
              Text('Assigned Floor', style: AppTextStyles.h6),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedFloor,
                decoration:
                    const InputDecoration(prefixIcon: Icon(Icons.layers)),
                style: isDark
                    ? AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.darkText)
                    : AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.lightText),
                dropdownColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                items: _floors
                    .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                          f,
                          style: isDark
                              ? AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.darkText)
                              : AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.lightText),
                        )))
                    .toList(),
                onChanged: (v) => setState(() => _selectedFloor = v),
              ),
              const SizedBox(height: 24),

              // Expertise
              Text('Expertise', style: AppTextStyles.h6),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpertiseType.values
                    .map((type) => FilterChip(
                          label: Text(type.displayName),
                          selected: _selectedExpertise.contains(type),
                          onSelected: (selected) => setState(() {
                            if (selected)
                              _selectedExpertise.add(type);
                            else
                              _selectedExpertise.remove(type);
                          }),
                          selectedColor:
                              AppColors.primaryDarkGreen.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryDarkGreen,
                          labelStyle: isDark
                              ? AppTextStyles.labelMedium
                                  .copyWith(color: AppColors.darkText)
                              : AppTextStyles.labelMedium
                                  .copyWith(color: AppColors.lightText),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Machine Assignment (only for technicians)
              if (_selectedRole == UserRole.technician) ...[
                Text('Assigned Machines', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                ...machines.map((machine) => CheckboxListTile(
                      title: Text(machine.name),
                      subtitle: Text(machine.location),
                      value: _selectedMachines.contains(machine.id),
                      onChanged: (v) => setState(() {
                        if (v == true)
                          _selectedMachines.add(machine.id);
                        else
                          _selectedMachines.remove(machine.id);
                      }),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    )),
                const SizedBox(height: 24),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Save Changes' : 'Create User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, bool isDark) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDarkGreen.withOpacity(0.15)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryDarkGreen
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(
                role == UserRole.technician
                    ? Icons.engineering
                    : Icons.supervisor_account,
                color: isSelected ? AppColors.primaryDarkGreen : AppColors.grey,
                size: 32),
            const SizedBox(height: 8),
            Text(role.displayName,
                style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.primaryDarkGreen : null,
                    fontWeight: isSelected ? FontWeight.bold : null)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final isEditing = widget.userId != null;
        final user = UserModel(
          id: widget.userId ?? const Uuid().v4(),
          fullName: _nameController.text.trim(),
          employeeId: _employeeIdController.text.trim(),
          email: _emailController.text.trim(),
          role: _selectedRole,
          assignedFloor: _selectedFloor,
          expertise: _selectedExpertise.toList(),
          assignedMachineIds: _selectedMachines.toList(),
        );

        // Use mock data service for prototype
        MockDataService().createOrUpdateUser(user);

        // Trigger provider refresh to update users list in management screen
        ref.read(usersProvider.notifier).state =
            List.from(MockDataService().users);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'User updated successfully'
                  : 'User created successfully'),
              backgroundColor: AppColors.healthy,
            ),
          );
          context.go('/admin/users');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.critical,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
