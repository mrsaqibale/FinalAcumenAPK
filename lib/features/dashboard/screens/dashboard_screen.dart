import 'package:acumen/features/profile/screens/new_user_profile_screen.dart';
import 'package:acumen/features/search/screens/search_screen.dart';
import 'package:acumen/features/profile/screens/mentors_screen.dart';
import 'package:acumen/features/chat/screens/chats_screen.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_bottom_nav.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_header.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_menu_items.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/notification/screens/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({super.key, this.username = 'User name'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Check for expired events when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkExpiredEvents();
      }
    });
  }

  Future<void> _checkExpiredEvents() async {
    try {
      final eventController = Provider.of<EventController>(
        context,
        listen: false,
      );
      await eventController.loadEvents();
      await eventController.checkForExpiredEvents(context);
    } catch (e) {
      debugPrint("Error checking expired events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_selectedIndex == 0) {
      bodyContent = Column(
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
      );
    } else {
      bodyContent = const NotificationsScreen();
    }

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
          icon: const Icon(
            FontAwesomeIcons.bars,
            color: AppColors.iconLight,
            size: 22,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: AppColors.iconLight,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/icons/user.png',
              color: AppColors.iconLight,
              height: 25,
              width: 25,
            ),
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
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tab1.png',
              height: 30,
              width: 30,
              color:
                  _selectedIndex == 0
                      ? AppColors.primary
                      : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/tab2.png',
              height: 24,
              width: 24,
              color: _selectedIndex == 1 ? AppColors.primary : Colors.grey,
            ),
            label: '',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
