import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Display order, left to right: Home, Scoliometer, Scan, Exercises, Progress.
  // navIndex is the original route index used by MobileLayout's onTap routing,
  // so existing navigation/highlighting logic keeps working unchanged.
  static const List<_NavItemData> _items = [
    _NavItemData(
      navIndex: 0,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavItemData(
      navIndex: 2,
      icon: Icons.speed_outlined,
      activeIcon: Icons.speed,
      label: 'Scoliometer',
    ),
    _NavItemData(
      navIndex: 1,
      icon: Icons.camera_alt,
      activeIcon: Icons.camera_alt,
      label: 'Scan',
      isFeatured: true,
    ),
    _NavItemData(
      navIndex: 3,
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center,
      label: 'Exercises',
    ),
    _NavItemData(
      navIndex: 4,
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Progress',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.map((item) {
            final isSelected = currentIndex == item.navIndex;
            return _NavItem(
              data: item,
              isSelected: isSelected,
              theme: theme,
              onTap: () => onTap(item.navIndex),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItemData {
  final int navIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isFeatured;

  const _NavItemData({
    required this.navIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isFeatured = false,
  });
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color purple = Color(0xFFB366CC); // featured accent
    final Color unselectedColor =
        theme.bottomNavigationBarTheme.unselectedItemColor ??
            theme.colorScheme.onSurfaceVariant;
    final Color selectedColor =
        theme.bottomNavigationBarTheme.selectedItemColor ??
            theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: data.isFeatured
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: purple, // purple circle behind the camera icon
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? data.activeIcon : data.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: purple,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? data.activeIcon : data.icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
