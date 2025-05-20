import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/events/widgets/event_item.dart';
import 'package:flutter/material.dart';

class AdminEventList extends StatelessWidget {
  final List<EventModel> events;
  final String emptyTitle;
  final String emptySubtitle;
  final RefreshCallback onRefresh;
  final Function(EventModel) onEventTap;

  const AdminEventList({
    super.key,
    required this.events,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final event = events[index];
          return EventItem(
            event: event,
            onTap: () => onEventTap(event),
          );
        },
      ),
    );
  }
} 