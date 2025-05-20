import 'package:acumen/features/events/models/event_model.dart';
import 'package:flutter/material.dart';

class AdminDeleteEventDialog extends StatelessWidget {
  final EventModel event;
  final VoidCallback onConfirm;

  const AdminDeleteEventDialog({
    super.key,
    required this.event,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Event'),
      content: Text('Are you sure you want to delete ${event.title}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
} 