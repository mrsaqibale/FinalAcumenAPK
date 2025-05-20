import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/resources/controllers/resources_tab_controller.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/widgets/resource_widgets.dart';
import 'package:acumen/features/resources/screens/resource_detail_screen.dart';
import 'dart:developer' as developer;

class ResourcesTabWidget extends StatefulWidget {
  const ResourcesTabWidget({super.key});

  @override
  State<ResourcesTabWidget> createState() => _ResourcesTabWidgetState();
}

class _ResourcesTabWidgetState extends State<ResourcesTabWidget> {
  late ResourcesTabController _controller;
  List<ResourceItem> _resources = [];
  bool _isLoading = true;
  String? _error;
  bool _showFilters = false;

  // Maps to hold categorized resources
  Map<String, List<ResourceItem>> _categorizedResources = {
    'Communities': [],
    'Chats': [],
    'Resources': [],
  };

  @override
  void initState() {
    super.initState();
    _controller = ResourcesTabController();
    _initializeResources();
  }

  Future<void> _initializeResources() async {
    try {
      await _controller.checkUserRole(context);
      final resources = await _controller.fetchResources();
      
      developer.log('Total resources fetched: ${resources.length}');
      
      // Categorize resources by source
      final Map<String, List<ResourceItem>> categorized = {
        'Communities': [],
        'Chats': [],
        'Resources': [],
      };
      
      for (var resource in resources) {
        developer.log('Resource: ${resource.title}, sourceType: ${resource.sourceType}, communityId: ${resource.communityId}, chatId: ${resource.chatId}');
        
        // Check if it's a community resource
        if (resource.communityId != null && resource.communityId!.isNotEmpty) {
          categorized['Communities']!.add(resource);
          developer.log('Added to Communities: ${resource.title}');
        } 
        // Check if it's a chat resource
        else if (resource.chatId != null && resource.chatId!.isNotEmpty) {
          categorized['Chats']!.add(resource);
          developer.log('Added to Chats: ${resource.title}');
        } 
        // Default to Resources category
        else {
          categorized['Resources']!.add(resource);
          developer.log('Added to Resources: ${resource.title}');
        }
      }
      
      developer.log('Categorized resources: Communities=${categorized['Communities']!.length}, Chats=${categorized['Chats']!.length}, Resources=${categorized['Resources']!.length}');
      
      setState(() {
        _resources = resources;
        _categorizedResources = categorized;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      developer.log('Error loading resources: $e', error: e);
      setState(() {
        _error = 'Failed to load resources: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshResources() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _initializeResources();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ResourcesTabController>(
        builder: (context, controller, _) {
          if (_isLoading) {
            return const ResourceLoadingIndicator();
          }

          if (_error != null) {
            return ResourceErrorWidget(
              message: _error!,
              onRetry: _refreshResources,
            );
          }

          if (_resources.isEmpty) {
            return EmptyResourcesWidget(
              message: 'No resources found. Try changing your filters.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshResources,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Resources',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                              onPressed: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_showFilters) ...[
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Filter by Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ResourceTypeFilter(
                          types: ['PDF', 'DOC', 'LINK', 'VIDEO', 'IMAGE', 'OTHER'],
                          selectedType: controller.selectedResourceTypeFilter,
                          onTypeSelected: (type) {
                            controller.setResourceTypeFilter(type);
                            _refreshResources();
                          },
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Filter by Source',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SourceFilter(
                          sources: const ['All', 'Resources', 'Chats', 'Communities'],
                          selectedSource: controller.selectedSourceFilter,
                          onSourceSelected: (source) {
                            controller.setSourceFilter(source);
                            _refreshResources();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                // Communities Section
                ..._buildResourceSection('Communities', _categorizedResources['Communities']!, controller),
                
                // Chats Section
                ..._buildResourceSection('Chats', _categorizedResources['Chats']!, controller),
                
                // Resources Section
                ..._buildResourceSection('Resources', _categorizedResources['Resources']!, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildResourceSection(String title, List<ResourceItem> resources, ResourcesTabController controller) {
    if (resources.isEmpty) {
      return [];
    }
    
    if (controller.selectedSourceFilter != 'All' && controller.selectedSourceFilter != title) {
      return [];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8, right: 16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${resources.length})',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final resource = resources[index];
            final canEdit = controller.canEditResource(resource);
            
            return ResourceCard(
              resource: resource,
              isSelected: controller.selectedResourceId == resource.id,
              canEdit: canEdit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResourceDetailScreen(resource: resource),
                  ),
                );
              },
              onEdit: canEdit
                  ? () => controller.editResource(context, resource)
                  : null,
              onDelete: canEdit
                  ? () => controller.deleteResource(context, resource)
                  : null,
              onShare: () => controller.shareResource(context, resource),
              onDetails: () => controller.showResourceDetails(context, resource),
            );
          },
          childCount: resources.length,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 