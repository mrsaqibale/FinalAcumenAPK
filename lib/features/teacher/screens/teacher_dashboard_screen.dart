import 'package:acumen/features/assignments/controllers/assignment_controller.dart';
import 'package:acumen/features/auth/models/user_model.dart';
import 'package:acumen/features/courses/models/course_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _HomeTab(),
            _CoursesTab(),
            _AssignmentsTab(),
            _ResourcesTab(),
            _CommunitiesTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Communities',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel>(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: currentUser.profileImageUrl != null
                          ? NetworkImage(currentUser.profileImageUrl!)
                          : null,
                      child: currentUser.profileImageUrl == null
                          ? Text(
                              currentUser.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${currentUser.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentUser.role.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickActions(context),
        const SizedBox(height: 16),
        _buildRecentActivity(context),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context,
                  Icons.assignment_add,
                  'Create Assignment',
                  () {
                    // Navigate to create assignment screen
                  },
                ),
                _buildActionItem(
                  context,
                  Icons.upload_file,
                  'Upload Resource',
                  () {
                    // Navigate to upload resource screen
                  },
                ),
                _buildActionItem(
                  context,
                  Icons.group_add,
                  'Create Community',
                  () {
                    // Navigate to create community screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // In a real app, you would fetch recent activities
    final activities = [
      {
        'title': 'New Assignment Created',
        'description': 'Midterm Project for CS101',
        'time': '2 hours ago',
        'icon': Icons.assignment,
        'color': Colors.orange,
      },
      {
        'title': 'Resource Shared',
        'description': 'Lecture Notes for MATH202',
        'time': '1 day ago',
        'icon': Icons.book,
        'color': Colors.blue,
      },
      {
        'title': 'Community Message',
        'description': 'New message in CS101 Community',
        'time': '2 days ago',
        'icon': Icons.chat,
        'color': Colors.green,
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildActivityItem(context, activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  activity['description'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch courses from a controller
    final courses = [
      CourseModel(
        id: 'CS101',
        name: 'Introduction to Computer Science',
        code: 'CS101',
        description: 'An introductory course to computer science concepts.',
        imageUrl: '',
        teacherId: 'teacher1',
        teacherName: 'Professor Johnson',
        studentIds: ['student1', 'student2', 'student3'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CourseModel(
        id: 'MATH202',
        name: 'Advanced Calculus',
        code: 'MATH202',
        description: 'A course covering advanced calculus topics.',
        imageUrl: '',
        teacherId: 'teacher1',
        teacherName: 'Professor Johnson',
        studentIds: ['student1', 'student4', 'student5'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create course screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...courses.map((course) => _buildCourseCard(context, course)),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course detail screen
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        course.code,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.studentIds.length} Students',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCourseAction(
                    context,
                    Icons.assignment,
                    'Assignments',
                    () {
                      // Navigate to course assignments
                    },
                  ),
                  _buildCourseAction(
                    context,
                    Icons.book,
                    'Resources',
                    () {
                      // Navigate to course resources
                    },
                  ),
                  _buildCourseAction(
                    context,
                    Icons.people,
                    'Students',
                    () {
                      // Navigate to course students
                    },
                  ),
                  _buildCourseAction(
                    context,
                    Icons.settings,
                    'Settings',
                    () {
                      // Navigate to course settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    final assignmentController = Provider.of<AssignmentController>(context);
    
    if (assignmentController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (assignmentController.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${assignmentController.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => assignmentController.loadAssignments(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final assignments = assignmentController.assignments;
    
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No assignments yet'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create assignment screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assignments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create assignment screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...assignments.map((assignment) => _buildAssignmentCard(context, assignment)),
      ],
    );
  }

  Widget _buildAssignmentCard(BuildContext context, dynamic assignment) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to assignment detail screen
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment.courseName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${assignment.dueDate.toString().substring(0, 10)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Max Points: ${assignment.maxPoints}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAssignmentAction(
                    context,
                    Icons.edit,
                    'Edit',
                    () {
                      // Navigate to edit assignment screen
                    },
                  ),
                  _buildAssignmentAction(
                    context,
                    Icons.people,
                    'Students',
                    () {
                      // Navigate to assignment students screen
                    },
                  ),
                  _buildAssignmentAction(
                    context,
                    Icons.delete,
                    'Delete',
                    () {
                      // Show delete confirmation dialog
                      _showDeleteConfirmation(context, assignment);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AssignmentController>(context, listen: false)
                  .deleteAssignment(assignment.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment deleted')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Resources Tab - Coming Soon'),
    );
  }
}

class _CommunitiesTab extends StatelessWidget {
  const _CommunitiesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Communities Tab - Coming Soon'),
    );
  }
} 