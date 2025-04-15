export 'admin_dashboard_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dummy data for users
  final List<Map<String, dynamic>> _admins = [
    {'name': 'Jacob willson', 'email': 'jacobwillson@gmail.com', 'isActive': true},
    {'name': 'Jacob willson', 'email': 'jacobwillson@gmail.com', 'isActive': false},
    {'name': 'Sarah Johnson', 'email': 'sarahjohnson@gmail.com', 'isActive': true},
    {'name': 'Michael Brown', 'email': 'michaelbrown@gmail.com', 'isActive': false},
  ];
  
  final List<Map<String, dynamic>> _mentors = [
    {'name': 'Emma Davis', 'email': 'emmadavis@gmail.com', 'isActive': true},
    {'name': 'James Wilson', 'email': 'jameswilson@gmail.com', 'isActive': false},
    {'name': 'Olivia Smith', 'email': 'oliviasmith@gmail.com', 'isActive': true},
    {'name': 'Robert Lee', 'email': 'robertlee@gmail.com', 'isActive': false},
  ];
  
  final List<Map<String, dynamic>> _students = [
    {'name': 'Daniel Taylor', 'email': 'danieltaylor@gmail.com', 'isActive': true},
    {'name': 'Sophia Anderson', 'email': 'sophiaanderson@gmail.com', 'isActive': false},
    {'name': 'William Harris', 'email': 'williamharris@gmail.com', 'isActive': true},
    {'name': 'Isabella Martin', 'email': 'isabellamartin@gmail.com', 'isActive': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
                      tabs: [
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
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUserList(_admins),
                        _buildUserList(_mentors),
                        _buildUserList(_students),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Show a snackbar for now
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add new user feature coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final user = users[index];
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user['email'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Active/Inactive switch with label
                Column(
                  children: [
                    Switch(
                      value: user['isActive'],
                      onChanged: (value) {
                        setState(() {
                          user['isActive'] = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(
                      user['isActive'] ? 'Active' : 'InActive',
                      style: TextStyle(
                        fontSize: 12,
                        color: user['isActive'] ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 
