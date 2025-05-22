import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> event;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(event['startDate'] as int);
    final endDate = DateTime.fromMillisecondsSinceEpoch(event['endDate'] as int);
    final now = DateTime.now();
    final isActive = endDate.isAfter(now) && (event['isActive'] as bool? ?? true);
    final imageUrl = event['imageUrl'] as String?;
    final title = event['title'] as String? ?? 'Untitled Event';
    final description = event['description'] as String? ?? 'No description available';
    final venue = event['venue'] as String? ?? 'No venue specified';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null && imageUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppTheme.primaryColor,
                      child: const Center(
                        child: Icon(
                          Icons.event,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Event Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Ended',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date and Time Section
                  _buildSection(
                    title: 'Date & Time',
                    icon: FontAwesomeIcons.calendar,
                    child: Column(
                      children: [
                        _buildDateTimeRow(
                          'Start',
                          startDate,
                          FontAwesomeIcons.clock,
                        ),
                        const SizedBox(height: 12),
                        _buildDateTimeRow(
                          'End',
                          endDate,
                          FontAwesomeIcons.clock,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Venue Section
                  _buildSection(
                    title: 'Venue',
                    icon: FontAwesomeIcons.locationDot,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            venue,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.mapLocationDot, color: AppTheme.primaryColor),
                          onPressed: () {
                            // TODO: Implement map navigation
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  _buildSection(
                    title: 'About Event',
                    icon: FontAwesomeIcons.circleInfo,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(String label, DateTime date, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(date),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 