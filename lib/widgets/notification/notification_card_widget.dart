import 'package:acumen/features/notification/models/notification_model.dart';
import 'package:acumen/features/notification/screens/notification_detail_screen.dart';
import 'package:flutter/material.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          if (onMarkAsRead != null) {
            onMarkAsRead!();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(notification: notification),
            ),
          );
        },
        onLongPress: () {
          _showOptions(context);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case 'assignment':
        iconColor = Colors.orange;
        iconData = Icons.assignment;
        break;
      case 'security':
        iconColor = Colors.red;
        iconData = Icons.security;
        break;
      case 'announcement':
        iconColor = Colors.blue;
        iconData = Icons.campaign;
        break;
      case 'account':
        iconColor = Colors.green;
        iconData = Icons.person;
        break;
      case 'enrollment':
        iconColor = Colors.purple;
        iconData = Icons.school;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.notifications;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read, color: Colors.blue),
                title: const Text('Mark as read', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  if (onMarkAsRead != null) {
                    onMarkAsRead!();
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete notification', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                if (onDelete != null) {
                  onDelete!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 