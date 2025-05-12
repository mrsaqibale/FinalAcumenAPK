import 'package:flutter/material.dart';

class CreateAssignmentDialogWidget {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Assignment'),
        content: const Text('Assignment creation feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 