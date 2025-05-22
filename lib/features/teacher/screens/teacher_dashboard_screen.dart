import 'package:acumen/features/teacher/controllers/teacher_dashboard_controller.dart';
import 'package:acumen/features/teacher/widgets/home_tab.dart';
import 'package:acumen/features/teacher/widgets/courses_tab.dart';
import 'package:acumen/features/teacher/widgets/assignments_tab.dart';
import 'package:acumen/features/teacher/widgets/resources_tab.dart';
import 'package:acumen/features/teacher/widgets/communities_tab.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherDashboardController(),
      child: const _TeacherDashboardScreenContent(),
    );
  }
}

class _TeacherDashboardScreenContent extends StatelessWidget {
  const _TeacherDashboardScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TeacherDashboardController>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IndexedStack(
          index: controller.selectedIndex,
          children: const [
            HomeTab(),
            CoursesTab(),
            AssignmentsTab(),
            ResourcesTab(),
            CommunitiesTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.selectedIndex,
        onTap: controller.setSelectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Communities',
          ),
        ],
      ),
    );
  }
} 