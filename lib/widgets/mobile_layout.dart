import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  final int currentNavIndex;

  const MobileLayout({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.currentNavIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav
          ? BottomNav(
              currentIndex: currentNavIndex,
              onTap: (index) {
                final routes = [
                  '/dashboard',
                  '/capture',
                  '/scoliometer',
                  '/exercises',
                  '/progress',
                ];
                if (index < routes.length) {
                  Navigator.pushReplacementNamed(context, routes[index]);
                }
              },
            )
          : null,
    );
  }
}
