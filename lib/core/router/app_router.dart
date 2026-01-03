import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/models/models.dart';
import '../../shared/data/services/auth_service.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/technician/presentation/screens/technician_shell.dart';
import '../../features/technician/presentation/screens/tickets_screen.dart';
import '../../features/technician/presentation/screens/ticket_detail_screen.dart';
import '../../features/technician/presentation/screens/machines_screen.dart';
import '../../features/technician/presentation/screens/machine_detail_screen.dart';
import '../../features/technician/presentation/screens/profile_screen.dart';
import '../../features/manager/presentation/screens/manager_shell.dart';
import '../../features/manager/presentation/screens/manager_dashboard_screen.dart';
import '../../features/manager/presentation/screens/manager_tickets_screen.dart';
import '../../features/manager/presentation/screens/manager_ticket_detail_screen.dart';
import '../../features/tickets/presentation/screens/create_ticket_screen.dart';
import '../../features/manager/presentation/screens/calendar_screen.dart';
import '../../features/manager/presentation/screens/analytics_screen.dart';
import '../../features/manager/presentation/screens/reports_screen.dart';
import '../../features/manager/presentation/screens/settings_screen.dart';
import '../../features/super_admin/presentation/screens/admin_shell.dart';
import '../../features/super_admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/super_admin/presentation/screens/factory_map_screen.dart';
import '../../features/super_admin/presentation/screens/user_management_screen.dart';
import '../../features/super_admin/presentation/screens/add_user_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        // Redirect to appropriate dashboard based on role
        switch (currentUser.role) {
          case UserRole.superAdmin:
            return '/admin/dashboard';
          case UserRole.manager:
            return '/manager/dashboard';
          case UserRole.technician:
            return '/technician/tickets';
        }
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Technician Routes
      ShellRoute(
        builder: (context, state, child) => TechnicianShell(child: child),
        routes: [
          GoRoute(
            path: '/technician/tickets',
            builder: (context, state) => const TicketsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTicketScreen(),
              ),
              GoRoute(
                path: ':ticketId',
                builder: (context, state) {
                  final ticketId = state.pathParameters['ticketId']!;
                  return TicketDetailScreen(ticketId: ticketId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/technician/machines',
            builder: (context, state) => const MachinesScreen(),
            routes: [
              GoRoute(
                path: ':machineId',
                builder: (context, state) {
                  final machineId = state.pathParameters['machineId']!;
                  return MachineDetailScreen(machineId: machineId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/technician/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Manager Routes
      ShellRoute(
        builder: (context, state, child) => ManagerShell(child: child),
        routes: [
          GoRoute(
            path: '/manager/dashboard',
            builder: (context, state) => const ManagerDashboardScreen(),
          ),
          GoRoute(
            path: '/manager/tickets',
            builder: (context, state) => const ManagerTicketsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTicketScreen(),
              ),
              GoRoute(
                path: ':ticketId',
                builder: (context, state) {
                  final ticketId = state.pathParameters['ticketId']!;
                  return ManagerTicketDetailScreen(ticketId: ticketId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/manager/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/manager/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/manager/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/manager/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Super Admin Routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/admin/factory-map',
            builder: (context, state) => const FactoryMapScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UserManagementScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddUserScreen(),
              ),
              GoRoute(
                path: 'edit/:userId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return AddUserScreen(userId: userId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});
