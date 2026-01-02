import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class TechnicianShell extends ConsumerStatefulWidget {
  final Widget child;

  const TechnicianShell({super.key, required this.child});

  @override
  ConsumerState<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends ConsumerState<TechnicianShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Tickets',
      path: '/technician/tickets',
    ),
    _NavItem(
      icon: Icons.precision_manufacturing_outlined,
      activeIcon: Icons.precision_manufacturing,
      label: 'Machines',
      path: '/technician/machines',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      path: '/technician/profile',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_currentIndex != i) {
          setState(() {
            _currentIndex = i;
          });
        }
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
      // Tablet layout with side navigation
      return Scaffold(
        body: Row(
          children: [
            // Side Navigation Rail
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
                context.go(_navItems[index].path);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              selectedIconTheme: IconThemeData(
                color: isDark
                    ? AppColors.primaryLightGreen
                    : AppColors.primaryDarkGreen,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.grey,
              ),
              selectedLabelTextStyle: TextStyle(
                color: isDark
                    ? AppColors.primaryLightGreen
                    : AppColors.primaryDarkGreen,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.grey,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              destinations: _navItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            // Main content
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Phone layout with bottom navigation
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                      context.go(item.path);
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryLightGreen.withOpacity(0.15)
                                : AppColors.primaryDarkGreen.withOpacity(0.1))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? (isDark
                                    ? AppColors.primaryLightGreen
                                    : AppColors.primaryDarkGreen)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.grey),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryLightGreen
                                      : AppColors.primaryDarkGreen)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.grey),
                            ),
                          ),
                        ],
                      ),
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
