import 'package:acumen/features/profile/screens/new_user_profile_screen.dart';
import 'package:acumen/features/search/screens/search_screen.dart';
import 'package:acumen/features/auth/screens/login_screen.dart';
import 'package:acumen/features/business/screens/career_counseling_screen.dart';
import 'package:acumen/features/profile/screens/mentors_screen.dart';
import 'package:acumen/features/chat/screens/chats_screen.dart';
import 'package:acumen/features/notification/screens/notifications_screen.dart';
import 'package:acumen/features/profile/screens/edit_profile_screen.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/features/profile/screens/settings_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'admin_dashboard_screen.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_bottom_nav.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_header.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_menu_items.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({
    super.key,
    this.username = 'User name',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.bars, color: AppColors.iconLight, size: 22),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.iconLight, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/images/icons/user.png', color: AppColors.iconLight, height: 25, width: 25),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewUserProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: DashboardDrawer(username: widget.username),
      body: Column(
        children: [
          DashboardHeader(username: widget.username),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: const DashboardMenuItems(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Handle navigation based on bottom nav selection
          if (index == 1) {
            // Navigate to Mentors screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MentorsScreen(),
              ),
            );
          } else if (index == 2) {
            // Navigate to Chats screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatsScreen(),
              ),
            );
          } else if (index == 3) {
            // Navigate to Profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewUserProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
} 
