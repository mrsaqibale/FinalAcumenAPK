import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/dashboard/widgets/communities_tab_widget.dart';
import 'package:acumen/features/dashboard/widgets/students_tab_widget.dart';
import 'package:acumen/features/dashboard/widgets/logout_dialog_widget.dart';
import 'package:acumen/features/resources/widgets/resources_tab_widget.dart';
import 'package:acumen/features/business/screens/mentor_quiz_tabs_screen.dart';
import 'package:acumen/features/dashboard/widgets/mentor_dashboard_fab_widget.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _authController = Provider.of<AuthController>(context, listen: false);
    
    // Add listener for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (kDebugMode) {
          print('Tab changed to index: ${_tabController.index}');
        }
        // Force UI update when tab changes
        setState(() {});
      }
    });
    
    // Check if user is still authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authController.currentUser == null) {
        // If not authenticated, navigate to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
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
        
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Mentor Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.white),
          onPressed: () => LogoutDialogWidget.show(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppTheme.primaryColor,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(179),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorPadding: const EdgeInsets.only(bottom: 4),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'COMMUNITIES'),
                Tab(text: 'STUDENTS'),
                Tab(text: 'RESOURCES'),
                Tab(text: 'QUIZ RESULTS'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              margin: const EdgeInsets.only(top: 0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  const CommunitiesTabWidget(),
                  const StudentsTabWidget(),
                  const ResourcesTabWidget(),
                  ChangeNotifierProvider.value(
                    value: QuizController.getInstance(),
                    child: const MentorQuizTabsScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: MentorDashboardFAB(tabController: _tabController),
      );
  }
} 