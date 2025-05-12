import 'package:acumen/features/notification/models/notification_model.dart';
import 'package:acumen/features/notification/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would fetch from an API or local database
      _notifications = [
        NotificationModel(
          id: '1',
          title: 'New assignment available',
          message: 'A new assignment has been posted for your course.',
          isRead: false,
          time: '2 hours ago',
          type: 'assignment',
          details: {
            'title': 'Final Project',
            'dueDate': 'May 25, 2025',
            'courseId': 'CS101',
            'courseName': 'Introduction to Computer Science',
          },
        ),
        NotificationModel(
          id: '2',
          title: 'Password changed',
          message: 'Your account password was successfully changed.',
          isRead: false,
          time: '1 day ago',
          type: 'security',
          details: {
            'timestamp': '2023-05-10T14:30:00Z',
            'ipAddress': '192.168.1.1',
            'device': 'Chrome on Windows',
          },
        ),
        NotificationModel(
          id: '3',
          title: 'New announcement',
          message: 'An announcement has been posted for your course.',
          isRead: false,
          time: '3 days ago',
          type: 'announcement',
          details: {
            'title': 'Class Canceled Tomorrow',
            'courseId': 'MATH202',
            'courseName': 'Advanced Calculus',
            'postedBy': 'Prof. Johnson',
          },
        ),
        NotificationModel(
          id: '4',
          title: 'New account created',
          message: 'Your student account has been successfully created.',
          isRead: true,
          time: '1 week ago',
          type: 'account',
          details: {
            'username': 'student123',
            'accountType': 'Student',
            'timestamp': '2023-05-05T10:15:00Z',
          },
        ),
        NotificationModel(
          id: '5',
          title: 'Course enrollment confirmed',
          message: 'You have been enrolled in a new course.',
          isRead: true,
          time: '2 weeks ago',
          type: 'enrollment',
          details: {
            'courseId': 'BIO101',
            'courseName': 'Introduction to Biology',
            'instructor': 'Dr. Smith',
            'startDate': 'June 1, 2023',
          },
        ),
      ];

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

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      
      // In a real app, you would update this on the server
      // await NotificationService.markAsRead(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    
    // In a real app, you would update this on the server
    // await NotificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    
    // In a real app, you would update this on the server
    // await NotificationService.deleteNotification(notificationId);
  }

  Future<void> clearAllNotifications() async {
    _notifications = [];
    notifyListeners();
    
    // In a real app, you would update this on the server
    // await NotificationService.clearAllNotifications();
  }

  // Add a new notification (for testing purposes)
  Future<void> addNewNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? details,
  }) async {
    final newNotification = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      isRead: false,
      time: 'Just now',
      type: type,
      details: details,
    );
    
    _notifications.insert(0, newNotification);
    notifyListeners();
    
    // In a real app, this would typically come from a push notification service
  }
} 