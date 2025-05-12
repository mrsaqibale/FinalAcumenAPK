import 'package:flutter/material.dart';

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String type; // pdf, doc, link, etc.
  final DateTime dateAdded;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dateAdded,
  });
}

class ResourcesTabWidget extends StatefulWidget {
  const ResourcesTabWidget({super.key});

  @override
  State<ResourcesTabWidget> createState() => _ResourcesTabWidgetState();
}

class _ResourcesTabWidgetState extends State<ResourcesTabWidget> {
  String? selectedResourceId;
  List<ResourceItem> _resources = [];

  @override
  void initState() {
    super.initState();
    // Sample resources - replace with real data
    _resources = [
      ResourceItem(
        id: '1',
        title: 'Course Syllabus',
        description: 'Complete course outline for the semester',
        type: 'pdf',
        dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ResourceItem(
        id: '2',
        title: 'Study Guide',
        description: 'Comprehensive study materials for exams',
        type: 'doc',
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ResourceItem(
        id: '3',
        title: 'Lecture Notes',
        description: 'Notes from the latest lecture',
        type: 'pdf',
        dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _showDeleteOptions(String resourceId) {
    setState(() {
      selectedResourceId = resourceId;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete resource', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(resourceId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.blue),
              title: const Text('Download', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _downloadResource(resourceId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Colors.green),
              title: const Text('Share', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _shareResource(resourceId);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        selectedResourceId = null;
      });
    });
  }

  void _showDeleteConfirmation(String resourceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this resource?'),
        content: const Text('This resource will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _resources.removeWhere((resource) => resource.id == resourceId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resource deleted')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _downloadResource(String resourceId) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading resource...')),
    );
  }

  void _shareResource(String resourceId) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing resource...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resources.isEmpty) {
      return const Center(
        child: Text(
          'No resources available yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        final resource = _resources[index];
        final isSelected = selectedResourceId == resource.id;
        
        return InkWell(
          onLongPress: () => _showDeleteOptions(resource.id),
          child: Container(
            color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: _getTypeColor(resource.type),
                  child: Icon(
                    _getTypeIcon(resource.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added ${_formatDate(resource.dateAdded)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  // View resource
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${resource.title}...')),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
        return Colors.blue;
      case 'link':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'link':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 