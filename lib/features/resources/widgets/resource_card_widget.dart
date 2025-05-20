import 'package:flutter/material.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';
import 'package:acumen/features/resources/widgets/resource_preview_widget.dart';
import 'package:acumen/theme/app_theme.dart';

class ResourceCardWidget extends StatelessWidget {
  final ResourceItem resource;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMorePressed;

  const ResourceCardWidget({
    super.key,
    required this.resource,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImageOrPdf = 
        resource.type.toLowerCase() == 'image' || 
        resource.type.toLowerCase() == 'pdf';
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resource type badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getSourceColor().withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resource.resourceType,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    _buildSourceChip(),
                  ],
                ),
              ),
              
              // Preview for image and PDF files
              if (isImageOrPdf && resource.fileUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ResourcePreviewWidget(
                    resource: resource,
                    height: 150,
                  ),
                ),
              
              // Resource content
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: !isImageOrPdf ? CircleAvatar(
                  backgroundColor: ResourceUtils.getTypeColor(resource.type),
                  child: Icon(
                    ResourceUtils.getTypeIcon(resource.type),
                    color: Colors.white,
                  ),
                ) : null,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Added ${ResourceUtils.formatDate(resource.dateAdded)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          'By ${resource.mentorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    if (resource.sourceType == 'Chat' && resource.chatName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From chat with ${resource.chatName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (resource.sourceType == 'Community' && resource.communityName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From community "${resource.communityName}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onMorePressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSourceChip() {
    IconData iconData;
    String label;
    Color color;
    
    switch (resource.sourceType) {
      case 'Chat':
        iconData = Icons.chat_bubble_outline;
        label = 'Chat';
        color = Colors.green;
        break;
      case 'Community':
        iconData = Icons.group;
        label = 'Community';
        color = Colors.orange;
        break;
      case 'Resource':
      default:
        iconData = Icons.folder_outlined;
        label = 'Resource';
        color = AppTheme.primaryColor;
        break;
    }
    
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
      backgroundColor: color.withOpacity(0.1),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSourceColor() {
    switch (resource.sourceType) {
      case 'Chat':
        return Colors.green;
      case 'Community':
        return Colors.orange;
      case 'Resource':
      default:
        return AppTheme.primaryColor;
    }
  }
} 