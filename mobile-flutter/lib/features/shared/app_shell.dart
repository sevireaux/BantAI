import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/repositories/auth_provider.dart';
import '../citizen/citizen_dashboard_screen.dart';
import '../citizen/citizen_map_screen.dart';
import '../citizen/citizen_reports_screen.dart';
import '../citizen/notifications_screen.dart';
import '../citizen/report_new_screen.dart';
import '../lgu/lgu_dashboard_screen.dart';
import '../lgu/lgu_reports_screen.dart';
import '../lgu/lgu_map_screen.dart';

/// One shell, tabs swapped based on role — citizens get Report/My
/// Reports/Map/Notifications; Barangay/LGU/System staff get
/// Dashboard/Reports/Map. This keeps navigation structurally consistent
/// (same shell, same animation, same bottom-bar styling) across roles
/// instead of two divergent app skeletons.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final isCitizen = user.isCitizen;

    final screens = isCitizen
        ? const [CitizenDashboardScreen(), ReportNewScreen(embedded: true), CitizenReportsScreen(), CitizenMapScreen(), NotificationsScreen()]
        : const [LguDashboardScreen(), LguReportsScreen(), LguMapScreen()];

    final items = isCitizen
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Report'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'My Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppMotion.base,
        switchInCurve: AppMotion.curve,
        switchOutCurve: AppMotion.curve,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(key: ValueKey(_index), child: screens[_index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: items,
      ),
    );
  }
}
