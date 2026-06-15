import 'package:expense_user/views/project/project_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_user/app_colors.dart';
import 'setting/setting_screen.dart';

// Bottom tab bar wrapper for Projects and Settings.
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() {
    return _MainWrapperState();
  }
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Pop the current tab's navigator on back press.
  Future<void> _handleBackPressed() async {
    NavigatorState? currentNavigator = _navigatorKeys[_currentIndex].currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
    }
  }

  // Wrap a tab child in its own nested navigator.
  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return child;
          },
        );
      },
    );
  }

  // Handle bottom nav tap: pop to root if same tab, otherwise switch.
  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // If the same tab is tapped, pop to the root of that tab.
      _navigatorKeys[index].currentState?.popUntil((Route<dynamic> route) {
        return route.isFirst;
      });
      return;
    }
    // Switch to the selected tab.
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _handleBackPressed();
      },
      child: Scaffold(
        // Tab content with persistent state via IndexedStack.
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildTabNavigator(0, const ProjectListScreen()),
            _buildTabNavigator(1, const SettingScreen()),
          ],
        ),
        // Bottom navigation bar.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}