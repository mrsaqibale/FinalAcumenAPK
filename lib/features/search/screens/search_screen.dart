import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/search/controllers/search_controller.dart' as acumen;
import 'package:acumen/features/search/widgets/search_widgets.dart';
import 'package:acumen/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => acumen.SearchController(),
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    bool enabled = await SettingsController.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    
    // Show the notification status message
    if (!value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifications disabled. You can re-enable them in settings.'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications enabled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Update settings globally
    final prefs = await SettingsController.areNotificationsEnabled();
    if (prefs != value) {
      // Create a temporary controller to toggle the setting
      final tempController = SettingsController();
      await tempController.toggleNotifications(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<acumen.SearchController>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: Colors.white,
            ),
            onPressed: () {
              _toggleNotifications(!_notificationsEnabled);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: controller.searchController),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Consumer<acumen.SearchController>(
                builder: (context, controller, _) {
                  // Show loading indicator while searching
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  // Show error if there is one
                  if (controller.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              controller.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              controller.searchController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!controller.hasSearchQuery) {
                    return InitialSuggestionsWidget(
                      featureItems: controller.getFeatureItems(),
                      onFeatureTap: (item) {
                        Navigator.pushNamed(context, item['route']);
                      },
                    );
                  }

                  if (controller.filteredItems.isEmpty) {
                    return NoResultsWidget(searchQuery: controller.searchQuery);
                  }

                  // Group search results by type
                  final Map<String, List<Map<String, dynamic>>> groupedResults = {
                    'community': [],
                    'user': [],
                    'resource': [],
                    'event': [],
                    'feature': [],
                  };
                  
                  for (var item in controller.filteredItems) {
                    final type = item['type'];
                    if (groupedResults.containsKey(type)) {
                      groupedResults[type]!.add(item);
                    }
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Communities section
                      if (groupedResults['community']!.isNotEmpty) ...[
                        _buildSearchResultSection(context, 'Communities', groupedResults['community']!),
                      ],
                      
                      // Users section
                      if (groupedResults['user']!.isNotEmpty) ...[
                        _buildSearchResultSection(context, 'People', groupedResults['user']!),
                      ],
                      
                      // Resources section
                      if (groupedResults['resource']!.isNotEmpty) ...[
                        _buildSearchResultSection(context, 'Resources', groupedResults['resource']!),
                      ],
                      
                      // Events section
                      if (groupedResults['event']!.isNotEmpty) ...[
                        _buildSearchResultSection(context, 'Events', groupedResults['event']!),
                      ],
                      
                      // Features section
                      if (groupedResults['feature']!.isNotEmpty) ...[
                        _buildSearchResultSection(context, 'Features', groupedResults['feature']!),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResultSection(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => SearchResultItemWidget(
          item: item,
          onTap: () {
            final route = item['route'];
            if (route != null) {
              Navigator.of(context).pushNamed(route);
            }
          },
        )).toList(),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
} 
