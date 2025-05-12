import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/screens/community_chat_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/widgets/chat/new_community_dialog_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/dashboard/widgets/communities_tab_widget.dart';
import 'package:acumen/features/dashboard/widgets/assignments_tab_widget.dart';
import 'package:acumen/features/dashboard/widgets/students_tab_widget.dart';
import 'package:acumen/features/dashboard/widgets/dashboard_fab_widget.dart';
import 'package:acumen/features/dashboard/widgets/mentor_tab_bar_widget.dart';
import 'package:acumen/features/dashboard/widgets/logout_dialog_widget.dart';
import 'package:acumen/features/dashboard/widgets/create_assignment_dialog_widget.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Mentor Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => LogoutDialogWidget.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          MentorTabBarWidget(tabController: _tabController),
          
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
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CommunitiesTabWidget(),
                  AssignmentsTabWidget(),
                  StudentsTabWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: DashboardFabWidget(
        currentTabIndex: _tabController.index,
        onCreateAssignment: () => CreateAssignmentDialogWidget.show(context),
      ),
    );
  }
} 