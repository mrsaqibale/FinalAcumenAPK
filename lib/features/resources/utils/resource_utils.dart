import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResourceUtils {
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
        return Colors.blue;
      case 'link':
        return Colors.green;
      case 'video':
        return Colors.orange;
      case 'image':
        return Colors.purple;
      case 'presentation':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'link':
        return Icons.link;
      case 'video':
        return Icons.video_library;
      case 'image':
        return Icons.image;
      case 'presentation':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static List<String> getResourceTypes() {
    return [
      'All',
      'Course Syllabus',
      'Assignment',
      'Announcement',
      'Lecture Notes',
      'MCQs',
      'Study Guide',
      'Presentation',
      'Reference Material',
      'Practice Test',
      'Tutorial',
      'Other'
    ];
  }
} 