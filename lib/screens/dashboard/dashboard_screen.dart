import 'package:acumen/screens/auth/login_screen.dart';
import 'package:acumen/screens/career/career_counseling_screen.dart';
import 'package:acumen/screens/mentors/mentors_screen.dart';
import 'package:acumen/screens/messaging/chats_screen.dart';
import 'package:acumen/screens/notifications/notifications_screen.dart';
import 'package:acumen/screens/profile/edit_profile_screen.dart';
import 'package:acumen/screens/profile/new_user_profile_screen.dart';
import 'package:acumen/screens/settings/settings_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'admin_dashboard_screen.dart';
import '../search/search_screen.dart';

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
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.bars, color: Colors.white, size: 22),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.white, size: 22),
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
            icon: Image.asset('assets/images/icons/user.png',color: Colors.white,height: 25,width: 25,),
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
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
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
                child: _buildMenuItems(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/profile-img.png'),
            ),
            accountName: Text(
              widget.username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('jacobwillson@gmail.com'),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.house, color: AppTheme.primaryColor, size: 20),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/user.png',color: Colors.black,height: 40,width: 20,),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewUserProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.userPen, color: AppTheme.primaryColor, size: 20),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(
              AssetImage('assets/images/icons/bell.png'),
              color: AppTheme.primaryColor,
              size: 22,
            ),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.solidMessage, color: AppTheme.primaryColor, size: 20),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.userShield, color: AppTheme.primaryColor, size: 20),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.gear, color: AppTheme.primaryColor, size: 20),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.red, size: 20),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Log out logic
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
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
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
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
                child: item['icon'] is String
                    ? Image.asset(
                        item['icon'] as String,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      )
                    : FaIcon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 16,
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
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
            color: _selectedIndex == 0 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/icons/tab2.png',
            height: 24,
            width: 24,
            color: _selectedIndex == 1 ? AppTheme.primaryColor : Colors.grey,
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
