import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/communities/models/community_model.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SearchController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = false;
  String? error;
  
  // Firebase references
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Feature menu items (not from database)
  final List<Map<String, dynamic>> _featureItems = [
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
      'title': 'Communities',
      'type': 'feature',
      'route': '/communities',
      'icon': FontAwesomeIcons.peopleGroup,
    },
    {
      'title': 'Profile',
      'type': 'feature',
      'route': '/profile',
      'icon': FontAwesomeIcons.userPen,
    },
    {
      'title': 'Resources',
      'type': 'feature', 
      'route': '/resources',
      'icon': FontAwesomeIcons.book,
    },
    {
      'title': 'Chat',
      'type': 'feature',
      'route': '/chats',
      'icon': FontAwesomeIcons.comment,
    },
  ];

  // Collections for real data
  List<Map<String, dynamic>> _communities = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _events = [];
  
  SearchController() {
    searchController.addListener(_onSearchChanged);
    _preloadData();
  }
  
  Future<void> _preloadData() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Load initial data sets
      await Future.wait([
        _loadCommunities(),
        _loadUsers(),
        _loadResources(),
        _loadEvents(),
      ]);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = 'Error loading search data: $e';
      if (kDebugMode) {
        print(error);
      }
      notifyListeners();
    }
  }
  
  Future<void> _loadCommunities() async {
    try {
      final snapshot = await _db.collection('communities').get();
      _communities = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Unknown Community',
          'description': data['description'] ?? 'No description available',
          'type': 'community',
          'memberCount': (data['members'] as List?)?.length ?? 0,
          'imageUrl': data['imageUrl'],
          'route': '/community/${doc.id}',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading communities: $e');
      }
    }
  }
  
  Future<void> _loadUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final snapshot = await _db.collection('users').limit(50).get();
      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Unknown User',
          'description': '${data['role'] ?? 'User'} • ${data['email'] ?? 'No email'}',
          'type': 'user',
          'photoUrl': data['photoUrl'],
          'role': data['role'] ?? 'student',
          'route': '/profile/${doc.id}',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }
  
  Future<void> _loadResources() async {
    try {
      final snapshot = await _db.collection('resources').limit(50).get();
      _resources = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Resource',
          'description': data['description'] ?? 'No description available',
          'type': 'resource',
          'resourceType': data['resourceType'] ?? data['fileType'] ?? 'Other',
          'fileUrl': data['fileUrl'],
          'mentorName': data['mentorName'] ?? 'Unknown',
          'route': '/resource/${doc.id}',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading resources: $e');
      }
    }
  }
  
  Future<void> _loadEvents() async {
    try {
      final now = DateTime.now();
      final snapshot = await _db.collection('events')
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('startDate')
          .limit(50)
          .get();
      
      _events = snapshot.docs.map((doc) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp?)?.toDate();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Event',
          'description': data['description'] ?? 'No description available',
          'type': 'event',
          'date': startDate != null 
              ? '${startDate.day}/${startDate.month}/${startDate.year}'
              : 'Date not available',
          'location': data['location'] ?? 'Location not specified',
          'route': '/event/${doc.id}',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading events: $e');
      }
    }
  }

  void _onSearchChanged() async {
    searchQuery = searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredItems = [];
      notifyListeners();
      return;
    }
    
    try {
      isLoading = true;
      notifyListeners();
      
      // If search has 3+ characters, refresh data from Firestore for more accurate results
      if (searchQuery.length > 2) {
        await _refreshSearchData();
      }
      
      // Search through all data sources
      filteredItems = [];
      
      // Search communities
      filteredItems.addAll(_communities.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description'].toString().toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }));
      
      // Search users
      filteredItems.addAll(_users.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description'].toString().toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }));
      
      // Search resources
      filteredItems.addAll(_resources.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description'].toString().toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }));
      
      // Search events
      filteredItems.addAll(_events.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description'].toString().toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }));
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = 'Error searching: $e';
      if (kDebugMode) {
        print(error);
      }
      notifyListeners();
    }
  }
  
  Future<void> _refreshSearchData() async {
    try {
      if (searchQuery.length < 3) return;
      
      // Limited real-time search for better performance
      await Future.wait([
        _searchCommunities(),
        _searchUsers(),
        _searchResources(),
        _searchEvents(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing search data: $e');
      }
    }
  }
  
  Future<void> _searchCommunities() async {
    try {
      // Search by name or description
      final snapName = await _db.collection('communities')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .limit(10)
          .get();
          
      // Process results same as _loadCommunities
      final results = snapName.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Unknown Community',
          'description': data['description'] ?? 'No description available',
          'type': 'community',
          'memberCount': (data['members'] as List?)?.length ?? 0,
          'imageUrl': data['imageUrl'],
          'route': '/community/${doc.id}',
        };
      }).toList();
      
      _communities = results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching communities: $e');
      }
    }
  }
  
  Future<void> _searchUsers() async {
    try {
      // Search by name
      final snapName = await _db.collection('users')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .limit(10)
          .get();
          
      // Process results same as _loadUsers
      final results = snapName.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Unknown User',
          'description': '${data['role'] ?? 'User'} • ${data['email'] ?? 'No email'}',
          'type': 'user',
          'photoUrl': data['photoUrl'],
          'role': data['role'] ?? 'student',
          'route': '/profile/${doc.id}',
        };
      }).toList();
      
      _users = results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
    }
  }
  
  Future<void> _searchResources() async {
    try {
      // Search by title
      final snapTitle = await _db.collection('resources')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .limit(10)
          .get();
          
      // Process results same as _loadResources
      final results = snapTitle.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Resource',
          'description': data['description'] ?? 'No description available',
          'type': 'resource',
          'resourceType': data['resourceType'] ?? data['fileType'] ?? 'Other',
          'fileUrl': data['fileUrl'],
          'mentorName': data['mentorName'] ?? 'Unknown',
          'route': '/resource/${doc.id}',
        };
      }).toList();
      
      _resources = results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching resources: $e');
      }
    }
  }
  
  Future<void> _searchEvents() async {
    try {
      // Search by title
      final snapTitle = await _db.collection('events')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .limit(10)
          .get();
          
      // Process results same as _loadEvents
      final results = snapTitle.docs.map((doc) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp?)?.toDate();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Event',
          'description': data['description'] ?? 'No description available',
          'type': 'event',
          'date': startDate != null 
              ? '${startDate.day}/${startDate.month}/${startDate.year}'
              : 'Date not available',
          'location': data['location'] ?? 'Location not specified',
          'route': '/event/${doc.id}',
        };
      }).toList();
      
      _events = results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching events: $e');
      }
    }
  }

  List<Map<String, dynamic>> getFeatureItems() {
    return _featureItems;
  }

  bool get hasSearchQuery => searchQuery.isNotEmpty || searchController.text.isNotEmpty;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
} 