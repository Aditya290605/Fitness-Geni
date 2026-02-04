import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/fit/presentation/screens/fit_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../core/constants/app_constants.dart';

/// Riverpod provider for managing bottom navigation tab index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation wrapper with bottom navigation bar
/// Contains Home, Fit, and Profile screens
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  /// List of screens for each tab
  static const List<Widget> _screens = [
    HomeScreen(),
    FitScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppConstants.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: AppConstants.tabFit,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppConstants.tabProfile,
          ),
        ],
      ),
    );
  }
}
