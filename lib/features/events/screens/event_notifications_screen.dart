import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/events/screens/event_detail_screen.dart';
import 'package:acumen/features/events/widgets/event_notification_item.dart';
import 'package:acumen/features/notification/controllers/notification_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class EventNotificationsScreen extends StatefulWidget {
  const EventNotificationsScreen({super.key});

  @override
  State<EventNotificationsScreen> createState() => _EventNotificationsScreenState();
}

class _EventNotificationsScreenState extends State<EventNotificationsScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid context issues during initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEvents();
    });
  }

  Future<void> _initializeEvents() async {
    if (_isInitialized) return;

    try {
      if (!mounted) return;
      final eventController = Provider.of<EventController>(context, listen: false);
      final notificationController = Provider.of<NotificationController>(context, listen: false);
      
      await eventController.loadEvents();
      
      if (!mounted) return;
      
      // Check for expired events
      try {
        await eventController.checkForExpiredEvents(context);
      } catch (e) {
        if (kDebugMode) {
          print('Error checking for expired events: $e');
        }
      }
      
      if (!mounted) return;
      
      // Sync with notifications
      try {
        await notificationController.syncWithEvents(eventController.activeEvents);
      } catch (e) {
        if (kDebugMode) {
          print('Error syncing with notifications: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading events: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final eventController = Provider.of<EventController>(context, listen: false);
      final notificationController = Provider.of<NotificationController>(context, listen: false);
      
      await eventController.loadEvents();
      
      if (!mounted) return;
      
      // Check for expired events
      try {
        await eventController.checkForExpiredEvents(context);
      } catch (e) {
        if (kDebugMode) {
          print('Error checking for expired events: $e');
        }
      }
      
      if (!mounted) return;
      
      // Sync with notifications
      try {
        await notificationController.syncWithEvents(eventController.activeEvents);
      } catch (e) {
        if (kDebugMode) {
          print('Error syncing with notifications: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reloading events: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEventDetails(EventModel event) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(
            eventId: event.id,
            event: {
              'title': event.title,
              'description': event.description,
              'venue': event.venue,
              'startDate': event.startDate.millisecondsSinceEpoch,
              'endDate': event.endDate.millisecondsSinceEpoch,
              'isActive': event.isActive,
              'imageUrl': event.imageUrl,
            },
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to event details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Upcoming Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<EventController>(
              builder: (context, eventController, child) {
                final activeEvents = eventController.activeEvents;
                
                if (activeEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Upcoming Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new events',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeEvents.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final event = activeEvents[index];
                      return EventNotificationItem(
                        event: event,
                        onTap: () => _showEventDetails(event),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
} 