import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/views/home/home_view.dart';
import 'package:uniqart/views/settings/settings_view.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final screens = const [
    HomeView(),
    SettingView(),
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            label: context.loc.main_navigator_home,
            icon: const Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            label: context.loc.main_navigator_setting,
            icon: const Icon(
              Icons.settings_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
