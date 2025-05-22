import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/profile/screens/user_profile_screen.dart';

class AdminUserList extends StatefulWidget {
  final List<UserModel> users;
  final String role;

  const AdminUserList({
    super.key,
    required this.users,
    required this.role,
  });

  @override
  State<AdminUserList> createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(AdminUserList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _filterUsers();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = widget.users;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredUsers = widget.users.where((user) {
        return user.name.toLowerCase().contains(query) ||
               user.email.toLowerCase().contains(query) ||
               (user.employeeId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  void _viewUserProfile(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          name: user.name,
          email: user.email,
          imageUrl: user.photoUrl ?? '',
          bio: user.education?['bio'] ?? 'No bio available',
          skills: user.skills ?? (user.education?['skills'] != null 
              ? List<dynamic>.from(user.education!['skills'])
              : []),
          isVerified: user.hasVerifiedSkills ?? false,
        ),
      ),
    );
  }
  
  void _viewUserProfileImage(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: user.photoUrl != null
                ? Image.network(
                    user.photoUrl!,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    FontAwesomeIcons.user,
                    size: 100,
                    color: Colors.white.withOpacity(0.6),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or employee ID',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        
        // User list
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No ${widget.role} users found'
                            : 'No users found matching "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<UserController>(context, listen: false)
                        .loadUsersByRole(widget.role);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(context, user);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return InkWell(
      onTap: () => _viewUserProfile(context, user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // User avatar
              GestureDetector(
                onTap: () => _viewUserProfileImage(context, user),
                child: Hero(
                  tag: 'profile-${user.id}',
                  child: _buildUserAvatar(user),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.hasVerifiedSkills == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              FontAwesomeIcons.solidCircleCheck,
                              color: Colors.blue,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (user.employeeId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${user.employeeId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Active/Inactive switch
              Column(
                children: [
                  Switch(
                    value: user.isActive,
                    onChanged: (value) {
                      Provider.of<UserController>(context, listen: false)
                          .updateUserActiveStatus(user, value);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                  Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.isActive ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    return CachedProfileImage(
      imageUrl: user.photoUrl,
      size: 40,
      radius: 20,
      backgroundColor: user.photoUrl == null 
          ? AppTheme.primaryColor.withOpacity(0.2)
          : Colors.white,
      placeholderIcon: FontAwesomeIcons.user,
      placeholderSize: 20,
      placeholderColor: AppTheme.primaryColor,
    );
  }
}