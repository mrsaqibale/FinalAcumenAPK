import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/profile/widgets/user_form.dart';
import 'package:acumen/features/dashboard/widgets/admin/admin_user_list.dart';
import 'package:acumen/features/dashboard/widgets/admin/admin_mentor_list.dart';
import 'package:acumen/features/dashboard/widgets/admin/admin_premium_skills_tab.dart';
import 'package:acumen/features/dashboard/widgets/logout_dialog_widget.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/events/widgets/admin/admin_delete_event_dialog.dart';
import 'package:acumen/features/events/widgets/admin/admin_event_details_dialog.dart';
import 'package:acumen/features/events/widgets/admin/admin_event_list.dart';
import 'package:flutter/foundation.dart';
import 'package:acumen/features/events/screens/add_event_screen.dart';
import 'package:acumen/features/business/screens/quiz_results_tab.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';

// New wrapper widget for QuizResultsTab to handle provider properly
class QuizResultsWrapper extends StatelessWidget {
  const QuizResultsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizController.getInstance(),
      child: const QuizResultsTab(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  late TabController _eventsTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _eventsTabController = TabController(length: 2, vsync: this);
    
    // Use addPostFrameCallback to ensure state updates happen after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUsers();
        _loadEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventsTabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    
    try {
      final userController = Provider.of<UserController>(context, listen: false);
      await userController.loadAllUsers();
      
      if (kDebugMode) {
        print("Pending mentor applications: ${userController.pendingTeacherApplications.length}");
        for (var mentor in userController.pendingTeacherApplications) {
          print("Pending mentor: ${mentor.name}, status: ${mentor.status}, approved: ${mentor.isApproved}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading users: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    
    try {
      final eventController = Provider.of<EventController>(context, listen: false);
      await eventController.loadEvents();
      
      // Check for expired events
      await eventController.checkForExpiredEvents(context);
    } catch (e) {
      if (kDebugMode) {
        print("Error loading events: $e");
      }
    }
  }

  String _getRoleForCurrentTab() {
    switch (_tabController.index) {
      case 0:
        return 'admin';
      case 1:
        return 'mentor';
      case 2:
        return 'student';
      case 3:
        return ''; // Events tab
      case 4:
        return ''; // Premium Skills tab
      default:
        return 'student';
    }
  }

  void _showAddEventDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    ).then((_) => _loadEvents());
  }

  void _showEventDetails(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AdminEventDetailsDialog(
        event: event,
        onEdit: () => _showEditEventDialog(event),
        onDelete: () => _showDeleteEventConfirmation(event),
      ),
    );
  }

  void _showEditEventDialog(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(eventToEdit: event),
      ),
    ).then((_) => _loadEvents());
  }

  void _showDeleteEventConfirmation(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteEventDialog(
        event: event,
        onConfirm: () async {
          final eventController = Provider.of<EventController>(context, listen: false);
          await eventController.deleteEvent(event.id);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event deleted successfully')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 0),
          child: Column(
            children: [
              SizedBox(height: 12),
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.white),
          onPressed: () => LogoutDialogWidget.show(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Column(
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
                    Tab(text: 'Events'),
                    Tab(text: 'Premium Skills'),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
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
                            // Events Tab - now shows content directly
                            Column(
                              children: [
                                // Events sub-tab bar
                                Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  child: TabBar(
                                    controller: _eventsTabController,
                                    isScrollable: false,
                                    labelColor: AppTheme.primaryColor,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: AppTheme.primaryColor,
                                    tabs: const [
                                      Tab(text: 'Running Events'),
                                      Tab(text: 'Past Events'),
                                    ],
                                  ),
                                ),
                                
                                // Events sub-tab content
                                Expanded(
                                  child: Consumer<EventController>(
                                    builder: (context, eventController, child) {
                                      return TabBarView(
                                        controller: _eventsTabController,
                                        children: [
                                          // Active events tab
                                          AdminEventList(
                                            events: eventController.activeEvents,
                                            emptyTitle: 'No active events',
                                            emptySubtitle: 'Create an event by tapping the + button below',
                                            onRefresh: _loadEvents,
                                            onEventTap: _showEventDetails,
                                          ),
                                          
                                          // Past events tab
                                          AdminEventList(
                                            events: eventController.pastEvents,
                                            emptyTitle: 'No past events',
                                            emptySubtitle: 'Past events and inactive events will appear here',
                                            onRefresh: _loadEvents,
                                            onEventTap: _showEventDetails,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            // Premium Skills Tab
                            const AdminPremiumSkillsTab(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
      floatingActionButton: _tabController.index == 4 ? null : FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 3) {
            _showAddEventDialog();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserForm(role: _getRoleForCurrentTab()),
              ),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: _tabController.index == 3 ? 'Add Event' : 
                _getRoleForCurrentTab().isEmpty ? 'Add' : 'Add ${_getRoleForCurrentTab().capitalize()}',
        child: Icon(
          _tabController.index == 0 
              ? Icons.admin_panel_settings 
              : _tabController.index == 1 
                  ? Icons.school 
                  : _tabController.index == 2
                      ? Icons.person_add
                      : Icons.add,
          color: Colors.white
        ),
      ),
    );
  }
} 
