import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class ManagerShell extends ConsumerStatefulWidget {
  final Widget child;
  const ManagerShell({super.key, required this.child});

  @override
  ConsumerState<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends ConsumerState<ManagerShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', path: '/manager/dashboard'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Tickets', path: '/manager/tickets'),
    _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendar', path: '/manager/calendar'),
    _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Analytics', path: '/manager/analytics'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', path: '/manager/settings'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_currentIndex != i) setState(() => _currentIndex = i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;

    if (isTablet) {
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
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('M', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 24))),
                ),
              ),
              destinations: _navItems.map((item) => NavigationRailDestination(icon: Icon(item.icon), selectedIcon: Icon(item.activeIcon), label: Text(item.label))).toList(),
            ),
            VerticalDivider(thickness: 1, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: AppDimensions.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () { setState(() => _currentIndex = index); context.go(item.path); },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? item.activeIcon : item.icon, color: isSelected ? (isDark ? AppColors.primaryLightGreen : AppColors.primaryDarkGreen) : AppColors.grey, size: 22),
                        const SizedBox(height: 2),
                        Text(item.label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? (isDark ? AppColors.primaryLightGreen : AppColors.primaryDarkGreen) : AppColors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem { final IconData icon, activeIcon; final String label, path; _NavItem({required this.icon, required this.activeIcon, required this.label, required this.path}); }
