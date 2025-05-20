import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userController = Provider.of<UserController>(context, listen: false);
      final userData = await userController.getUserById(widget.userId);
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            Hero(
                              tag: 'profile-${widget.userId}',
                              child: GestureDetector(
                                onTap: () {
                                  // Show full-screen profile image
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
                                            child: Image.network(
                                              _userData!['profileImage'] ?? 'https://via.placeholder.com/150',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(_userData!['profileImage'] ?? 'https://via.placeholder.com/150'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData!['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData!['role'] ?? 'student',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      
                      // Personal Information
                      _buildSectionHeader('Personal Information'),
                      _buildInfoItem('Email', _userData!['email'] ?? 'N/A'),
                      _buildInfoItem('Phone', _userData!['phone'] ?? 'N/A'),
                      _buildInfoItem('Location', _userData!['location'] ?? 'N/A'),
                      
                      // Education Information
                      _buildSectionHeader('Education'),
                      _buildInfoItem('Degree', _userData!['education']?['degree'] ?? 'N/A'),
                      _buildInfoItem('Institution', _userData!['education']?['institution'] ?? 'N/A'),
                      _buildInfoItem('Graduation Year', _userData!['education']?['graduationYear']?.toString() ?? 'N/A'),
                      
                      // Quiz Statistics
                      _buildSectionHeader('Quiz Statistics'),
                      _buildInfoItem('Quizzes Taken', _userData!['quizStats']?['totalQuizzes']?.toString() ?? '0'),
                      _buildInfoItem('Average Score', '${_userData!['quizStats']?['averageScore'] ?? 0}%'),
                      _buildInfoItem('Last Quiz Date', _userData!['quizStats']?['lastQuizDate'] ?? 'N/A'),
                      
                      // Recent Quiz Results
                      if (_userData!['recentQuizzes'] != null && (_userData!['recentQuizzes'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Recent Quiz Results'),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_userData!['recentQuizzes'] as List).length,
                              itemBuilder: (context, index) {
                                final quiz = (_userData!['recentQuizzes'] as List)[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(quiz['title'] ?? 'Quiz'),
                                    subtitle: Text('Date: ${quiz['date']}'),
                                    trailing: Text(
                                      '${quiz['score']}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (quiz['score'] as int) >= 70 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 