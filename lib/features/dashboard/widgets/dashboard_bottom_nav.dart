import 'package:acumen/features/notification/screens/notifications_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        onTap(index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab1.png',
            height: 30,
            width: 30,
            color: selectedIndex == 0 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/icons/tab2.png',
            height: 24,
            width: 24,
            color: selectedIndex == 1 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: '',
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
} 