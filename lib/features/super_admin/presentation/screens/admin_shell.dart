import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', path: '/admin/dashboard'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Users', path: '/admin/users'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) { if (_currentIndex != i) setState(() => _currentIndex = i); break; }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) { setState(() => _currentIndex = index); context.go(_navItems[index].path); },
            labelType: NavigationRailLabelType.all,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            selectedIconTheme: IconThemeData(color: isDark ? AppColors.primaryLightGreen : AppColors.primaryDarkGreen),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(width: 48, height: 48, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('M', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 24)))),
            ),
            destinations: _navItems.map((item) => NavigationRailDestination(icon: Icon(item.icon), selectedIcon: Icon(item.activeIcon), label: Text(item.label))).toList(),
          ),
          VerticalDivider(thickness: 1, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _NavItem { final IconData icon, activeIcon; final String label, path; _NavItem({required this.icon, required this.activeIcon, required this.label, required this.path}); }
