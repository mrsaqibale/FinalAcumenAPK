import 'package:flutter/material.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';

class ResourceCard extends StatelessWidget {
  final ResourceItem resource;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onDetails;
  final bool isSelected;
  final bool canEdit;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onDetails,
    this.isSelected = false,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resource.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canEdit) ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete,
                            tooltip: 'Delete',
                            color: Colors.red,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: onShare,
                          tooltip: 'Share',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: onDetails,
                          tooltip: 'Details',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInfoChip(
                      context,
                      icon: Icons.category,
                      label: resource.resourceType,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      icon: Icons.person,
                      label: resource.mentorName,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      icon: Icons.calendar_today,
                      label: ResourceUtils.formatDate(resource.dateAdded),
                    ),
                    if (resource.sourceType != 'Resource') ...[
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        icon: resource.sourceType == 'Chat'
                            ? Icons.chat
                            : Icons.group,
                        label: resource.sourceType == 'Chat'
                            ? 'Chat: ${resource.chatName}'
                            : 'Community: ${resource.communityName}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ResourceFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ResourceFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class ResourceTypeFilter extends StatelessWidget {
  final List<String> types;
  final String? selectedType;
  final Function(String?) onTypeSelected;

  const ResourceTypeFilter({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ResourceFilterChip(
            label: 'All',
            isSelected: selectedType == null,
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: 8),
          ...types.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ResourceFilterChip(
                  label: type,
                  isSelected: selectedType == type,
                  onTap: () => onTypeSelected(type),
                ),
              )),
        ],
      ),
    );
  }
}

class SourceFilter extends StatelessWidget {
  final List<String> sources;
  final String selectedSource;
  final Function(String) onSourceSelected;

  const SourceFilter({
    super.key,
    required this.sources,
    required this.selectedSource,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: sources.map((source) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ResourceFilterChip(
            label: source,
            isSelected: selectedSource == source,
            onTap: () => onSourceSelected(source),
          ),
        )).toList(),
      ),
    );
  }
}

class ResourceLoadingIndicator extends StatelessWidget {
  const ResourceLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading resources...'),
        ],
      ),
    );
  }
}

class ResourceErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ResourceErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 16,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyResourcesWidget extends StatelessWidget {
  final String message;

  const EmptyResourcesWidget({
    super.key,
    this.message = 'No resources found',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 