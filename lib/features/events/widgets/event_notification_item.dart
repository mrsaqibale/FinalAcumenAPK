import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventNotificationItem extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventNotificationItem({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysUntilEvent = event.startDate.difference(now).inDays;
    
    // Determine urgency color based on proximity to event
    Color urgencyColor;
    if (daysUntilEvent <= 1) {
      urgencyColor = Colors.red;
    } else if (daysUntilEvent <= 3) {
      urgencyColor = Colors.orange;
    } else {
      urgencyColor = AppTheme.primaryColor;
    }

    String timeMessage;
    if (now.isAfter(event.startDate) && now.isBefore(event.endDate)) {
      timeMessage = 'Happening now';
    } else if (daysUntilEvent == 0) {
      timeMessage = 'Today at ${DateFormat('hh:mm a').format(event.startDate)}';
    } else if (daysUntilEvent == 1) {
      timeMessage = 'Tomorrow at ${DateFormat('hh:mm a').format(event.startDate)}';
    } else {
      timeMessage = DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(event.startDate);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event icon with colored background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event,
                  color: urgencyColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            timeMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: urgencyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 