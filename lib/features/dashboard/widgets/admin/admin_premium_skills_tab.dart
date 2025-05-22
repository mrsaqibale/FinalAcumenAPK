import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/features/profile/repositories/profile_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/features/profile/repositories/user_repository.dart';

class AdminPremiumSkillsTab extends StatefulWidget {
  const AdminPremiumSkillsTab({super.key});

  @override
  State<AdminPremiumSkillsTab> createState() => _AdminPremiumSkillsTabState();
}

class _AdminPremiumSkillsTabState extends State<AdminPremiumSkillsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> _verifiedUsers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load pending verifications and verified users in parallel
      final results = await Future.wait([
        ProfileRepository.getPendingSkillVerifications(),
        ProfileRepository.getVerifiedSkillUsers(),
      ]);

      setState(() {
        _pendingVerifications = results[0];
        _verifiedUsers = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifySkill(String userId, String skillId, String skillName) async {
    try {
      // Verify the skill
      await ProfileRepository.verifySkill(userId, skillId);
      
      // Update user's verified status in the database
      final userRepository = UserRepository();
      await userRepository.checkAndUpdateUserVerifiedSkills(userId);
      
      // Update the local lists
      setState(() {
        // Remove from pending list
        final userIndex = _pendingVerifications.indexWhere(
          (item) => item['userId'] == userId && item['skillId'] == skillId
        );
        
        if (userIndex != -1) {
          final userName = _pendingVerifications[userIndex]['userName'];
          final userPhotoUrl = _pendingVerifications[userIndex]['userPhotoUrl'];
          
          _pendingVerifications.removeAt(userIndex);
          
          // Add to verified users list if not already there
          final verifiedUserIndex = _verifiedUsers.indexWhere(
            (item) => item['userId'] == userId
          );
          
          if (verifiedUserIndex != -1) {
            // Add to existing user's verified skills
            _verifiedUsers[verifiedUserIndex]['verifiedSkills'].add(skillName);
          } else {
            // Add new user to verified list
            _verifiedUsers.add({
              'userId': userId,
              'userName': userName,
              'userPhotoUrl': userPhotoUrl,
              'verifiedSkills': [skillName],
            });
          }
        }
      });
      
      AppSnackbar.showSuccess(
        context: context,
        message: 'Skill verified successfully',
      );
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error verifying skill: $e',
      );
    }
  }

  Future<void> _rejectSkill(String userId, String skillId) async {
    try {
      await ProfileRepository.rejectSkill(userId, skillId);
      
      // Update the local list
      setState(() {
        _pendingVerifications.removeWhere(
          (item) => item['userId'] == userId && item['skillId'] == skillId
        );
      });
      
      AppSnackbar.showSuccess(
        context: context,
        message: 'Skill verification rejected',
      );
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error rejecting skill: $e',
      );
    }
  }

  Future<void> _openFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open file';
      }
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error opening file: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading data: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pending Approvals'),
            Tab(text: 'Verified Users'),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pending approvals tab
              _buildPendingVerificationsTab(),
              
              // Verified users tab
              _buildVerifiedUsersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingVerificationsTab() {
    if (_pendingVerifications.isEmpty) {
      return const Center(
        child: Text(
          'No pending skill verifications',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _pendingVerifications.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final verification = _pendingVerifications[index];
          final userName = verification['userName'] ?? 'Unknown';
          final skillName = verification['skillName'] ?? 'Unknown Skill';
          final fileUrl = verification['fileUrl'] ?? '';
          final fileType = verification['fileType'] ?? 'pdf';
          final userId = verification['userId'];
          final skillId = verification['skillId'];
          final userPhotoUrl = verification['userPhotoUrl'];
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: userPhotoUrl != null 
                            ? NetworkImage(userPhotoUrl) 
                            : const AssetImage('assets/images/profile-img.png') as ImageProvider,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Skill: $skillName',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // File attachment
                  InkWell(
                    onTap: () => _openFile(fileUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            fileType == 'pdf' ? FontAwesomeIcons.filePdf : FontAwesomeIcons.fileImage,
                            color: fileType == 'pdf' ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'View Attachment',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.open_in_new, size: 18),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => _rejectSkill(userId, skillId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () => _verifySkill(userId, skillId, skillName),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.check, size: 14),
                              SizedBox(width: 8),
                              Text('Verify'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerifiedUsersTab() {
    if (_verifiedUsers.isEmpty) {
      return const Center(
        child: Text(
          'No users with verified skills',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _verifiedUsers.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final user = _verifiedUsers[index];
          final userName = user['userName'] ?? 'Unknown';
          final userEmail = user['userEmail'] ?? '';
          final userPhotoUrl = user['userPhotoUrl'];
          final verifiedSkills = List<String>.from(user['verifiedSkills'] ?? []);
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: userPhotoUrl != null 
                            ? NetworkImage(userPhotoUrl) 
                            : const AssetImage('assets/images/profile-img.png') as ImageProvider,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (userEmail.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Verified skills
                  const Text(
                    'Verified Skills:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: verifiedSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: Colors.blue,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  skill,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 