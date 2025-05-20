import 'package:acumen/features/notification/controllers/notification_controller.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/notification/notification_card_widget.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:acumen/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _areNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Load notifications and events when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if notifications are enabled in settings
      final areEnabled = await SettingsController.areNotificationsEnabled();
      setState(() {
        _areNotificationsEnabled = areEnabled;
      });
      
      if (!_areNotificationsEnabled) return;
      
      final notificationController = Provider.of<NotificationController>(context, listen: false);
      final eventController = Provider.of<EventController>(context, listen: false);
      
      // Load events and notifications in parallel
      await Future.wait([
        notificationController.loadNotifications(),
        eventController.loadEvents(),
      ]);
      
      // Sync notifications with active events
      await notificationController.syncWithEvents(eventController.activeEvents);
    });
  }

  Future<void> _refreshNotifications() async {
    // Check if notifications are enabled before refreshing
    final areEnabled = await SettingsController.areNotificationsEnabled();
    setState(() {
      _areNotificationsEnabled = areEnabled;
    });
    
    if (!_areNotificationsEnabled) return;
    
    final notificationController = Provider.of<NotificationController>(context, listen: false);
    final eventController = Provider.of<EventController>(context, listen: false);
    
    // Load events and notifications in parallel
    await Future.wait([
      notificationController.loadNotifications(),
      eventController.loadEvents(),
    ]);
    
    // Sync notifications with active events
    await notificationController.syncWithEvents(eventController.activeEvents);
  }

  void _navigateToDashboard() {
    // Clear the navigation stack and push the dashboard screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
      (route) => false,
    );
  }

  void _navigateToSettings() {
    // Navigate to settings screen
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: _navigateToDashboard,
        ),
        actions: [
          if (_areNotificationsEnabled)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  Provider.of<NotificationController>(context, listen: false).markAllAsRead();
                } else if (value == 'clear_all') {
                  _showClearConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear all notifications'),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: !_areNotificationsEnabled 
            ? _buildNotificationsDisabledMessage()
            : Consumer<NotificationController>(
                builder: (context, notificationController, child) {
                  final notifications = notificationController.notifications;
                  
                  if (notificationController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You don\'t have any notifications yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationCardWidget(
                          notification: notification,
                          onMarkAsRead: () => notificationController.markAsRead(notification.id),
                          onDelete: () => notificationController.deleteNotification(notification.id),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
     
    );
  }

  Widget _buildNotificationsDisabledMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Notifications are disabled',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You need to enable notifications in settings to receive updates',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This will remove all notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<NotificationController>(context, listen: false).clearAllNotifications();
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 
