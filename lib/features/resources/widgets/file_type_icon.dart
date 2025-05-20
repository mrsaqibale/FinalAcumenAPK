import 'package:flutter/material.dart';

IconData getFileTypeIcon(String type) {
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

Color getFileTypeColor(String type) {
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

class FileTypeIcon extends StatelessWidget {
  final String type;
  final double size;
  const FileTypeIcon({super.key, required this.type, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Icon(
      getFileTypeIcon(type),
      color: getFileTypeColor(type),
      size: size,
    );
  }
} 