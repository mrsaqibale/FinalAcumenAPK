import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/chat/new_community_dialog_widget.dart';
import 'package:acumen/features/resources/screens/add_resource_screen.dart';
import 'package:acumen/features/business/screens/add_quiz_screen.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';

class MentorDashboardFAB extends StatefulWidget {
  final TabController tabController;

  const MentorDashboardFAB({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  State<MentorDashboardFAB> createState() => _MentorDashboardFABState();
}

class _MentorDashboardFABState extends State<MentorDashboardFAB> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.tabController.index;
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted && _currentTabIndex != widget.tabController.index) {
      setState(() {
        _currentTabIndex = widget.tabController.index;
        if (kDebugMode) {
          print('Tab changed to: $_currentTabIndex');
        }
      });
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0: return 'COMMUNITIES';
      case 1: return 'STUDENTS';
      case 2: return 'RESOURCES';
      case 3: return 'QUIZ RESULTS';
      default: return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building FAB for tab index: $_currentTabIndex');
      print('Current tab name: ${_getTabName(_currentTabIndex)}');
    }

    return _buildFABForTab(_currentTabIndex, context);
  }

  Widget _buildFABForTab(int tabIndex, BuildContext context) {
    // Quiz Results tab (index 3)
    if (tabIndex == 3) {
      if (kDebugMode) {
        print('Showing Quiz FAB');
      }
      return FloatingActionButton(
        heroTag: 'quiz_fab',
        onPressed: () async {
          if (kDebugMode) {
            print('Quiz FAB pressed');
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: QuizController.getInstance(),
                child: const AddQuizScreen(),
              ),
            ),
          );
          
          if (result == true && mounted) {
            if (kDebugMode) {
              print('Quiz added successfully');
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz added successfully!')),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Add Quiz',
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    
    // Communities tab (index 0)
    if (tabIndex == 0) {
      return FloatingActionButton(
        heroTag: 'community_fab',
        onPressed: () => NewCommunityDialogWidget.show(context),
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Add Community',
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    
    // Resources tab (index 2)
    if (tabIndex == 2) {
      return FloatingActionButton(
        heroTag: 'resource_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddResourceScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Upload Resource',
        child: const Icon(Icons.upload_file, color: Colors.white),
      );
    }
    
    // No FAB for other tabs
    return const SizedBox.shrink();
  }
} 