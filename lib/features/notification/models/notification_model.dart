class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String time;
  final String type; // 'assignment', 'security', 'announcement', 'account', etc.
  final Map<String, dynamic>? details;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.time,
    required this.type,
    this.details,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    String? time,
    String? type,
    Map<String, dynamic>? details,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      time: time ?? this.time,
      type: type ?? this.type,
      details: details ?? this.details,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      time: json['time'] as String,
      type: json['type'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'isRead': isRead,
      'time': time,
      'type': type,
      'details': details,
    };
  }
} 