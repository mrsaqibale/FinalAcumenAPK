import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/widgets/mentor_card_widget.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MentorsScreen extends StatefulWidget {
  const MentorsScreen({super.key});

  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  bool _isLoading = true;
  bool _showInactive = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    try {
      final userController = Provider.of<UserController>(context, listen: false);
      await userController.loadUsersByRole('mentor');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<UserModel> _filterMentors(List<UserModel> mentors) {
    return mentors.where((mentor) {
      // Filter by active status if needed
      if (!_showInactive && !mentor.isActive) {
        return false;
      }
      
      // Filter by search query if provided
      if (_searchQuery.isNotEmpty) {
        return mentor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (mentor.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Mentors',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_showInactive 
                    ? 'Showing all mentors' 
                    : 'Showing only active mentors'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search mentors...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<UserController>(
                      builder: (context, userController, child) {
                        final filteredMentors = _filterMentors(userController.mentors);
                        
                        if (filteredMentors.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No mentors match your search'
                                      : _showInactive
                                          ? 'No mentors found'
                                          : 'No active mentors found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty || !_showInactive)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _showInactive = true;
                                      });
                                    },
                                    child: const Text('Show all mentors'),
                                  ),
                              ],
                            ),
                          );
                        }
                        
                        return RefreshIndicator(
                          onRefresh: _loadMentors,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            itemCount: filteredMentors.length,
                            itemBuilder: (context, index) {
                              final mentor = filteredMentors[index];
                              return MentorCardWidget(mentor: mentor);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 
