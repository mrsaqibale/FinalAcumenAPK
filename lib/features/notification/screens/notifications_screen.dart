import 'package:acumen/features/notification/controllers/notification_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/notification/notification_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationController>(context, listen: false).loadNotifications();
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Consumer<NotificationController>(
          builder: (context, notificationController, child) {
            if (notificationController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notificationController.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${notificationController.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => notificationController.loadNotifications(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final notifications = notificationController.notifications;

            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => notificationController.loadNotifications(),
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
