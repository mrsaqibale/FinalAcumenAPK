import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'admin_user_list.dart';
import 'admin_mentor_list.dart';

class AdminDashboardTabs extends StatefulWidget {
  final Function(int) onTabChanged;
  final int initialIndex;

  const AdminDashboardTabs({
    super.key,
    required this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  State<AdminDashboardTabs> createState() => _AdminDashboardTabsState();
}

class _AdminDashboardTabsState extends State<AdminDashboardTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      widget.onTabChanged(_tabController.index);
    }
  }

  @override
  void didUpdateWidget(AdminDashboardTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar 
        Container(
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withAlpha(179),
                indicatorColor: Colors.white,
                indicatorWeight: 2.0,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  insets: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                dividerHeight: 0,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Admins'),
                  Tab(text: 'Mentors'),
                  Tab(text: 'Students'),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
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
              child: Consumer<UserController>(
                builder: (context, userController, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      AdminUserList(users: userController.admins, role: 'admin'),
                      AdminMentorList(userController: userController),
                      AdminUserList(users: userController.students, role: 'student'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
} 