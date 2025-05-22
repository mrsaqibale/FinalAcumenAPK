import 'package:acumen/features/notification/models/notification_model.dart';
import 'package:acumen/features/notification/services/notification_service.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationController() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get notifications from the service
      _notifications = await NotificationService.getNotifications();

      // Clean up expired event notifications
      _removeExpiredEventNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading notifications: $e');
      }
      notifyListeners();
    }
  }

  // Check and remove notifications for expired events
  void _removeExpiredEventNotifications() {
    final now = DateTime.now();
    final expiredNotifications = <String>[];
    
    for (final notification in _notifications) {
      if (notification.type == 'event' && notification.details != null) {
        final endDate = DateTime.fromMillisecondsSinceEpoch(
          notification.details!['endDate'] as int
        );
        
        if (endDate.isBefore(now)) {
          expiredNotifications.add(notification.id);
        }
      }
    }
    
    // Remove expired notifications
    if (expiredNotifications.isNotEmpty) {
      for (final id in expiredNotifications) {
        deleteNotification(id);
      }
    }
  }

  // Create event notifications based on active events
  Future<void> syncWithEvents(List<EventModel> events) async {
    // Remove notifications for expired events first
    _removeExpiredEventNotifications();
    
    if (events.isEmpty) return;
    
    // Keep track of valid event IDs
    final validEventIds = events.map((e) => e.id).toSet();
    
    // Remove notifications for events that no longer exist or are not active
    final notificationsToRemove = _notifications
        .where((n) => 
            n.type == 'event' && 
            n.details != null && 
            !validEventIds.contains(n.details!['eventId']))
        .map((n) => n.id)
        .toList();
    
    for (final id in notificationsToRemove) {
      deleteNotification(id);
    }
    
    // Add event notifications to our list
    for (final event in events) {
      var existingNotificationIndex = _notifications.indexWhere(
        (n) => n.type == 'event' && n.details != null && n.details!['eventId'] == event.id
      );
      
      if (existingNotificationIndex >= 0) {
        // Update existing notification if needed
        // Check if end date has changed
        final existingEndDate = DateTime.fromMillisecondsSinceEpoch(
          _notifications[existingNotificationIndex].details!['endDate'] as int
        );
        
        if (existingEndDate != event.endDate) {
          // Remove the old notification and create a new one
          deleteNotification(_notifications[existingNotificationIndex].id);
          existingNotificationIndex = -1; // Force creation of new notification
        } else {
          continue; // Skip if no updates needed
        }
      }

      // Skip creating notification if event is already expired
      final now = DateTime.now();
      if (event.endDate.isBefore(now)) {
        continue;
      }

      // Create a new notification for this event
      final daysUntilEvent = event.startDate.difference(now).inDays;
      
      String timeMessage;
      if (now.isAfter(event.startDate) && now.isBefore(event.endDate)) {
        timeMessage = 'Happening now until ${DateFormat('MMM dd, hh:mm a').format(event.endDate)}';
      } else if (daysUntilEvent == 0) {
        timeMessage = 'Today at ${DateFormat('hh:mm a').format(event.startDate)}';
      } else if (daysUntilEvent == 1) {
        timeMessage = 'Tomorrow at ${DateFormat('hh:mm a').format(event.startDate)}';
      } else {
        timeMessage = DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(event.startDate);
      }
      
      final notificationMessage = 'Location: ${event.venue}. ${event.description}';
      
      final newNotification = NotificationModel(
        id: const Uuid().v4(),
        title: event.title,
        message: notificationMessage,
        isRead: false,
        time: 'Event on ${DateFormat('MMM dd').format(event.startDate)}',
        type: 'event',
        details: {
          'eventId': event.id,
          'startDate': event.startDate.millisecondsSinceEpoch,
          'endDate': event.endDate.millisecondsSinceEpoch,
          'venue': event.venue,
          'timeMessage': timeMessage,
          'imageUrl': event.imageUrl,
        },
      );
      
      _notifications.insert(0, newNotification);
    }
    
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await NotificationService.clearAllNotifications();
      _notifications = [];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all notifications: $e');
      }
    }
  }

  // Add a new notification (for testing purposes)
  Future<void> addNewNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? details,
  }) async {
    try {
      final newNotification = NotificationModel(
        id: const Uuid().v4(),
        title: title,
        message: message,
        isRead: false,
        time: 'Just now',
        type: type,
        details: details,
      );
      
      // In a real app, this would be saved to the server first
      // await NotificationService.addNotification(newNotification);
      
      _notifications.insert(0, newNotification);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding new notification: $e');
      }
    }
  }

  // Add a message notification
  Future<void> addMessageNotification({
    required String senderName,
    required String message,
    required String senderId,
    required String conversationId,
  }) async {
    try {
      final newNotification = NotificationModel(
        id: const Uuid().v4(),
        title: 'New message from $senderName',
        message: message,
        isRead: false,
        time: 'Just now',
        type: 'message',
        details: {
          'senderId': senderId,
          'conversationId': conversationId,
          'senderName': senderName,
        },
      );
      
      // Remove any existing message notifications from the same sender
      _notifications.removeWhere((n) => 
        n.type == 'message' && 
        n.details != null && 
        n.details!['senderId'] == senderId
      );
      
      // Add the new notification at the top
      _notifications.insert(0, newNotification);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding message notification: $e');
      }
    }
  }

  // Remove message notifications for a specific conversation
  Future<void> removeMessageNotifications(String conversationId) async {
    try {
      _notifications.removeWhere((n) => 
        n.type == 'message' && 
        n.details != null && 
        n.details!['conversationId'] == conversationId
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing message notifications: $e');
      }
    }
  }
} 