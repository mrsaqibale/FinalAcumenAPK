import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';

class MentorTabBarWidget extends StatelessWidget {
  final TabController tabController;

  const MentorTabBarWidget({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Communities'),
          Tab(text: 'Assignments'),
          Tab(text: 'Students'),
        ],
      ),
    );
  }
} 