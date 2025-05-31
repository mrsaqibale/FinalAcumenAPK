import '../models/notification_model.dart';
import '../../chat/screens/chat_detail_screen.dart';
import '../../../theme/app_theme.dart';
import '../../events/screens/event_notifications_screen.dart';
import '../widgets/notification_detail_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Any initialization that needs to happen after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Any state updates that need to happen after the first frame
    });
  }

  void _navigateToChat() {
    if (widget.notification.type == 'message' && widget.notification.details != null) {
      final conversationId = widget.notification.details!['conversationId'] as String;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            conversationId: conversationId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Notification Details',
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            NotificationDetailWidgets.buildHeader(widget.notification),
            const SizedBox(height: 20),
            NotificationDetailWidgets.buildContent(widget.notification),
            if (widget.notification.details != null) ...[
              const SizedBox(height: 20),
              NotificationDetailWidgets.buildDetails(widget.notification),
            ],
            if (widget.notification.type == 'event') ...[
              const SizedBox(height: 20),
              NotificationDetailWidgets.buildEventActions(context),
            ],
            if (widget.notification.type == 'message') ...[
              const SizedBox(height: 20),
              NotificationDetailWidgets.buildMessageActions(context, _navigateToChat),
            ],
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    final formattedKey = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .trim();
    
    return formattedKey.substring(0, 1).toUpperCase() + formattedKey.substring(1);
  }

  Widget _buildNotificationIcon() {
    final iconColor = NotificationModel.getColorForType(widget.notification.type);
    final iconData = NotificationModel.getIconForType(widget.notification.type);

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
} 
