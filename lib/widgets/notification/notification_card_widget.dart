import 'package:acumen/features/notification/models/notification_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/events/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Extract event image if this is an event notification
    String? eventImageUrl;
    if (notification.type == 'event' && notification.details != null) {
      eventImageUrl = notification.details!['imageUrl'] as String?;
    }
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            onMarkAsRead();
          }
          // Handle notification tap
          _handleNotificationTap(context);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
            border: notification.isRead
                ? Border.all(color: Colors.grey[200]!)
                : Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eventImageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    eventImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getIconColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getIconColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Notification content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notification.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (!notification.isRead) ...[
                                const Spacer(),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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

  IconData _getIcon() {
    return NotificationModel.getIconForType(notification.type);
  }

  Color _getIconColor() {
    return NotificationModel.getColorForType(notification.type);
  }

  void _handleNotificationTap(BuildContext context) {
    // Handle different notification types
    switch (notification.type) {
      case 'event':
        if (notification.details != null) {
          // Navigate to event details using direct navigation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(
                eventId: notification.details!['eventId'] as String,
                event: {
                  'title': notification.title,
                  'description': notification.message,
                  'venue': notification.details!['venue'] as String? ?? 'No venue specified',
                  'startDate': notification.details!['startDate'] as int,
                  'endDate': notification.details!['endDate'] as int,
                  'isActive': true, // Since this is an active event notification
                  'imageUrl': notification.details!['imageUrl'] as String?, // Get imageUrl from notification details
                },
              ),
            ),
          );
        }
        break;
      case 'announcement':
        // Handle announcement tap
        break;
      case 'reminder':
        // Handle reminder tap
        break;
      default:
        // Default action
        break;
    }
  }
} 