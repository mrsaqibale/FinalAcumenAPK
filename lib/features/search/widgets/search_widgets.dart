import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        controller: controller,
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
    );
  }
}

class FeatureCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const FeatureCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
}

class SearchResultItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const SearchResultItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = item['type'];
    
    switch (type) {
      case 'feature':
        return _buildFeatureItem(context);
      case 'event':
        return _buildEventItem(context);
      case 'community':
        return _buildCommunityItem(context);
      case 'user':
        return _buildUserItem(context);
      case 'resource':
        return _buildResourceItem(context);
      default:
        return _buildGenericItem(context);
    }
  }

  Widget _buildFeatureItem(BuildContext context) {
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
      onTap: onTap,
    );
  }

  Widget _buildEventItem(BuildContext context) {
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
      onTap: onTap,
    );
  }
  
  Widget _buildCommunityItem(BuildContext context) {
    return ListTile(
      leading: item['imageUrl'] != null 
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['imageUrl'],
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.peopleGroup,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
        : Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              FontAwesomeIcons.peopleGroup,
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
      subtitle: Row(
        children: [
          const Icon(Icons.people, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text('${item['memberCount'] ?? 0} members'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['description'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildUserItem(BuildContext context) {
    return ListTile(
      leading: item['photoUrl'] != null 
        ? ClipOval(
            child: Image.network(
              item['photoUrl'],
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          )
        : CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              FontAwesomeIcons.user,
              color: Colors.white,
              size: 18,
            ),
          ),
      title: Text(
        item['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(item['description'] ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildResourceItem(BuildContext context) {
    IconData iconData;
    Color iconColor;
    
    final resourceType = (item['resourceType'] ?? '').toString().toLowerCase();
    
    if (resourceType.contains('pdf')) {
      iconData = FontAwesomeIcons.filePdf;
      iconColor = Colors.red;
    } else if (resourceType.contains('doc')) {
      iconData = FontAwesomeIcons.fileWord;
      iconColor = Colors.blue;
    } else if (resourceType.contains('image') || resourceType.contains('png') || resourceType.contains('jpg')) {
      iconData = FontAwesomeIcons.fileImage;
      iconColor = Colors.green;
    } else if (resourceType.contains('video')) {
      iconData = FontAwesomeIcons.fileVideo;
      iconColor = Colors.purple;
    } else if (resourceType.contains('link')) {
      iconData = FontAwesomeIcons.link;
      iconColor = Colors.cyan;
    } else {
      iconData = FontAwesomeIcons.file;
      iconColor = Colors.grey;
    }
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        item['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('${item['mentorName'] ?? 'Unknown'} • ${item['description'] ?? ''}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildArticleItem(BuildContext context) {
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
      onTap: onTap,
    );
  }
  
  Widget _buildGenericItem(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.search,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        item['title'] ?? 'Unknown',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(item['description'] ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class NoResultsWidget extends StatelessWidget {
  final String searchQuery;

  const NoResultsWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
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
            'No results found for "$searchQuery"',
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
}

class InitialSuggestionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> featureItems;
  final Function(Map<String, dynamic>) onFeatureTap;

  const InitialSuggestionsWidget({
    super.key,
    required this.featureItems,
    required this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
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
              children: featureItems
                  .map((item) => FeatureCardWidget(
                        item: item,
                        onTap: () => onFeatureTap(item),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
} 