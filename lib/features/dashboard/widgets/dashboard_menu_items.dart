import 'package:acumen/features/business/screens/career_counseling_screen.dart';
import 'package:acumen/features/chat/screens/chats_screen.dart';
import 'package:acumen/features/notification/screens/notifications_screen.dart';
import 'package:acumen/features/profile/screens/edit_profile_screen.dart';
import 'package:acumen/features/profile/screens/mentors_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardMenuItems extends StatelessWidget {
  const DashboardMenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'career counceling',
        'subtitle': 'Strength your future by quiz',
        'icon': 'assets/images/icons/career.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CareerCounselingScreen(),
            ),
          );
        },
      },
      {
        'title': 'Mentorship',
        'subtitle': 'Connect to get guidance',
        'icon': 'assets/images/icons/chartboard.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MentorsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Event Managment',
        'subtitle': 'Event to explore',
        'icon': 'assets/images/icons/calendar.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatsScreen(initialTabIndex: 1),
            ),
          );
        },
      },
      {
        'title': 'Update Profile',
        'subtitle': 'Keep your data up-to-date',
        'icon': 'assets/images/icons/user.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
        },
      },
      {
        'title': 'Notification',
        'subtitle': 'view all notification here',
        'icon': 'assets/images/icons/bell.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: menuItems.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black12,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            minLeadingWidth: 35,
            leading: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  item['icon'] as String,
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20, color: Color.fromARGB(255, 0, 0, 0), weight: 700),
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      },
    );
  }
} 