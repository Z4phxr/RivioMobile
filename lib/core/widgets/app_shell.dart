import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_theme_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/habits/day');
        break;
      case 1:
        context.go('/sleep/day');
        break;
      case 2:
        context.go('/mood/day');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final appTheme = ref.watch(appThemeProvider);

    // Update current index based on path
    if (currentPath.startsWith('/habits')) {
      _currentIndex = 0;
    } else if (currentPath.startsWith('/sleep')) {
      _currentIndex = 1;
    } else if (currentPath.startsWith('/mood')) {
      _currentIndex = 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Rivio',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        actions: [
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: appTheme.accentColor.withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: Icon(
              Icons.check_circle,
              color: appTheme.primaryColor,
            ),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bedtime_outlined),
            selectedIcon: Icon(Icons.bedtime, color: appTheme.primaryColor),
            label: 'Sleep',
          ),
          NavigationDestination(
            icon: const Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood, color: appTheme.primaryColor),
            label: 'Mood',
          ),
        ],
      ),
    );
  }
}
