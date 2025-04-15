import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> _allItems = [
    {
      'title': 'Career Counseling',
      'type': 'feature',
      'route': '/career-counseling',
      'icon': FontAwesomeIcons.chartBar,
    },
    {
      'title': 'Mentorship',
      'type': 'feature',
      'route': '/mentors',
      'icon': FontAwesomeIcons.personChalkboard,
    },
    {
      'title': 'Events',
      'type': 'feature',
      'route': '/chats',
      'icon': FontAwesomeIcons.calendar,
    },
    {
      'title': 'Profile',
      'type': 'feature',
      'route': '/profile',
      'icon': FontAwesomeIcons.userPen,
    },
    {
      'title': 'Notifications',
      'type': 'feature', 
      'route': '/notifications',
      'icon': FontAwesomeIcons.bell,
    },
    {
      'title': 'Settings',
      'type': 'feature',
      'route': '/settings',
      'icon': FontAwesomeIcons.gear,
    },
    {
      'title': 'Time Management Workshop',
      'type': 'event',
      'date': 'June 15, 2023',
      'description': 'Learn effective time management techniques',
    },
    {
      'title': 'Career Fair',
      'type': 'event',
      'date': 'July 10, 2023',
      'description': 'Connect with potential employers',
    },
    {
      'title': 'IT Career Paths',
      'type': 'article',
      'author': 'John Smith',
      'description': 'Exploring various career paths in IT',
    },
    {
      'title': 'Resume Building Tips',
      'type': 'article',
      'author': 'Emily Johnson',
      'description': 'How to create a standout resume',
    },
  ];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description']?.toString().toLowerCase() ?? '';
        return title.contains(_searchQuery) || description.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for features, events, articles...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white38, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _searchQuery.isEmpty && _searchController.text.isEmpty
                ? _buildInitialSuggestions()
                : _filteredItems.isEmpty
                  ? _buildNoResultsFound()
                  : _buildSearchResults(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _allItems
                  .where((item) => item['type'] == 'feature')
                  .take(6)
                  .map((item) => _buildFeatureCard(item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, item['route']);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item['icon'],
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        if (item['type'] == 'feature') {
          return _buildFeatureItem(item);
        } else if (item['type'] == 'event') {
          return _buildEventItem(item);
        } else {
          return _buildArticleItem(item);
        }
      },
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item['icon'],
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        item['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text('Feature'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(context, item['route']);
      },
    );
  }

  Widget _buildEventItem(Map<String, dynamic> item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          FontAwesomeIcons.calendar,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        item['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('${item['date']} • ${item['description']}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to event details
      },
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          FontAwesomeIcons.bookOpen,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        item['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('By ${item['author']} • ${item['description']}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to article details
      },
    );
  }
} 
