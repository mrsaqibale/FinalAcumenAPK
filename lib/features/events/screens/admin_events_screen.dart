import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/events/widgets/add_event_form.dart';
import 'package:acumen/features/events/widgets/admin/admin_delete_event_dialog.dart';
import 'package:acumen/features/events/widgets/admin/admin_event_details_dialog.dart';
import 'package:acumen/features/events/widgets/admin/admin_event_list.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final eventController = Provider.of<EventController>(context, listen: false);
      await eventController.loadEvents();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 400,
          child: const AddEventForm(),
        ),
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 400,
          child: AddEventForm(eventToEdit: event),
        ),
      ),
    );
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
        title: const Text(
          'Event Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Column(
            children: [
              // Tab bar
              Container(
                color: AppTheme.primaryColor,
                child: TabBar(
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
                    Tab(text: 'Running Events'),
                    Tab(text: 'Past Events'),
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
                    child: Consumer<EventController>(
                      builder: (context, eventController, child) {
                        return TabBarView(
                          controller: _tabController,
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
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Add Event',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 