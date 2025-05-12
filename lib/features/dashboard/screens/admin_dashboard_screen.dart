export 'admin_dashboard_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/widgets/user_form.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/widgets/admin/mentor_applications_list.dart';
import 'package:flutter/foundation.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Load users data
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userController = Provider.of<UserController>(context, listen: false);
      await userController.loadAllUsers();
      
      // Log the number of pending applications for debugging
      if (kDebugMode) {
        print("Pending teacher applications: ${userController.pendingTeacherApplications.length}");
        for (var teacher in userController.pendingTeacherApplications) {
          print("Pending teacher: ${teacher.name}, status: ${teacher.status}, approved: ${teacher.isApproved}");
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            
            children: [
          const SizedBox(height: 12),

              const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Blue background
          Container(
            color: AppTheme.primaryColor,
            height: double.infinity,
          ),
          
          Column(
            children: [
              // Tab bar 
              Container(
                color: AppTheme.primaryColor,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withAlpha(179),
                      indicatorColor: Colors.white,
                      indicatorWeight: 2.0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        insets: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      dividerHeight: 0,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Admins'),
                        Tab(text: 'Mentors'),
                        Tab(text: 'Students'),
                      ],
                    ),
                    const SizedBox(height: 15), // Space after tabs
                  ],
                ),
              ),
              
              // Remaining space
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Consumer<UserController>(
                        builder: (context, userController, child) {
                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUserList(userController.admins, 'admin'),
                              _buildMentorsWithTeacherApplications(userController),
                              _buildUserList(userController.students, 'student'),
                            ],
                          );
                        },
                      ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open user form based on current tab
          String role = 'student';
          switch (_tabController.index) {
            case 0:
              role = 'admin';
              break;
            case 1:
              role = 'mentor';
              break;
            case 2:
              role = 'student';
              break;
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserForm(role: role),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, String role) {
    if (users.isEmpty) {
      return Center(child: Text('No $role users found'));
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<UserController>(context, listen: false).loadUsersByRole(role);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final user = users[index];
          final bool isPendingApproval = (role == 'teacher' || role == 'mentor') && 
              user.status == 'pending_approval' && 
              !(user.isApproved ?? false);
          
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
                      // User avatar
                      _buildUserAvatar(user),
                      const SizedBox(width: 16),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (isPendingApproval)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Pending Approval',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Active/Inactive switch and Approval button
                      Column(
                        children: [
                          // Active/Inactive switch
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
                          // Approval button for mentors
                          if (role == 'mentor' && user.isApproved == false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ElevatedButton(
                                onPressed: () => _showApprovalConfirmation(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(80, 30),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Approval button for pending teachers
                  if (role == 'teacher' && isPendingApproval)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () => _showApprovalConfirmation(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text('Approve Teacher Account'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showApprovalConfirmation(UserModel user) {
    final role = user.role == 'mentor' ? 'mentor' : 'teacher';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve ${role.capitalize()} Account'),
        content: Text('Are you sure you want to approve ${user.name} as a $role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<UserController>(context, listen: false)
                  .approveTeacherAccount(user);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been approved as a $role')),
              );
            },
            child: const Text('APPROVE', style: TextStyle(color: Colors.green)),
          ),
        ],
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

  Widget _buildMentorsWithTeacherApplications(UserController userController) {
    final pendingApplications = userController.pendingTeacherApplications;
    
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
                      if (pendingApplications.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            pendingApplications.length.toString(),
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
                _buildUserList(userController.mentors, 'mentor'),
                const MentorApplicationsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
