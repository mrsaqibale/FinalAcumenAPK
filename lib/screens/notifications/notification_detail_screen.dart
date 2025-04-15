import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildNotificationContent(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context) {
    if (notification['type'] == 'assignment') {
      return _buildAssignmentContent(context);
    } else if (notification['type'] == 'security') {
      return _buildSecurityContent(context);
    } else if (notification['type'] == 'announcement') {
      return _buildAnnouncementContent(context);
    } else {
      return _buildDefaultContent(context);
    }
  }

  Widget _buildAssignmentContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification['message'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Assignment Title:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification['details']['title'],
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Due Date:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification['details']['dueDate'],
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification['message'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'If you did not make this change, please contact support immediately.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification['message'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Please check your course page for more details.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Text(
      notification['message'],
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
} 
