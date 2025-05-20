import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/widgets/admin/mentor_applications_list.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminMentorList extends StatefulWidget {
  final UserController userController;

  const AdminMentorList({
    super.key,
    required this.userController,
  });

  @override
  State<AdminMentorList> createState() => _AdminMentorListState();
}

class _AdminMentorListState extends State<AdminMentorList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _filteredMentors = [];

  @override
  void initState() {
    super.initState();
    _filteredMentors = widget.userController.mentors;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(AdminMentorList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userController.mentors != widget.userController.mentors) {
      _filterMentors();
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
      _filterMentors();
    });
  }

  void _filterMentors() {
    if (_searchQuery.isEmpty) {
      _filteredMentors = widget.userController.mentors;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredMentors = widget.userController.mentors.where((mentor) {
        return mentor.name.toLowerCase().contains(query) ||
               mentor.email.toLowerCase().contains(query) ||
               (mentor.employeeId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                const Tab(text: 'Mentors'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mentor Applications'),
                      if (widget.userController.pendingTeacherApplications.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.userController.pendingTeacherApplications.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMentorList(context),
                const MentorApplicationsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorList(BuildContext context) {
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
        
        // Mentor list
        Expanded(
          child: _filteredMentors.isEmpty
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
                            ? 'No mentors found'
                            : 'No mentors found matching "$_searchQuery"',
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
                    await widget.userController.loadUsersByRole('mentor');
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMentors.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final mentor = _filteredMentors[index];
                      return _buildMentorCard(context, mentor);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMentorCard(BuildContext context, UserModel mentor) {
    return Container(
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
        child: Column(
          children: [
            Row(
              children: [
                // Mentor avatar
                _buildMentorAvatar(mentor),
                const SizedBox(width: 16),
                // Mentor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mentor.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (mentor.employeeId != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${mentor.employeeId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mentor.isApproved == true 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              mentor.isApproved == true ? 'Approved' : 'Pending Approval',
                              style: TextStyle(
                                color: mentor.isApproved == true ? Colors.green : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Approval toggle
                          GestureDetector(
                            onTap: () => _showApprovalToggleDialog(context, mentor),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    mentor.isApproved == true ? Icons.check_circle : Icons.pending,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Change Status',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Active/Inactive switch
                Column(
                  children: [
                    Switch(
                      value: mentor.isActive,
                      onChanged: (value) {
                        widget.userController.updateUserActiveStatus(mentor, value);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(
                      mentor.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: mentor.isActive ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorAvatar(UserModel mentor) {
    return CachedProfileImage(
      imageUrl: mentor.photoUrl,
      size: 40,
      radius: 20,
      backgroundColor: mentor.photoUrl == null 
          ? AppTheme.primaryColor.withOpacity(0.2)
          : Colors.white,
      placeholderIcon: FontAwesomeIcons.user,
      placeholderSize: 20,
      placeholderColor: AppTheme.primaryColor,
    );
  }

  void _showApprovalToggleDialog(BuildContext context, UserModel mentor) {
    final isCurrentlyApproved = mentor.isApproved == true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentlyApproved ? 'Revoke Approval?' : 'Approve Mentor?'),
        content: Text(
          isCurrentlyApproved
              ? 'Are you sure you want to revoke ${mentor.name}\'s mentor approval? This will prevent them from accessing mentor features.'
              : 'Are you sure you want to approve ${mentor.name} as a mentor? This will grant them access to mentor features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.userController.updateMentorApprovalStatus(mentor, !isCurrentlyApproved);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCurrentlyApproved
                        ? '${mentor.name}\'s mentor approval has been revoked'
                        : '${mentor.name} has been approved as a mentor',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isCurrentlyApproved ? Colors.red : Colors.green,
            ),
            child: Text(isCurrentlyApproved ? 'REVOKE' : 'APPROVE'),
          ),
        ],
      ),
    );
  }
} 