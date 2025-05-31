import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/repositories/profile_repository.dart';
import 'package:acumen/features/profile/screens/view_profile_screen.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';

class SkilledPersonsScreen extends StatefulWidget {
  const SkilledPersonsScreen({super.key});

  @override
  State<SkilledPersonsScreen> createState() => _SkilledPersonsScreenState();
}

class _SkilledPersonsScreenState extends State<SkilledPersonsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _verifiedUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVerifiedUsers();
  }

  Future<void> _loadVerifiedUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await ProfileRepository.getVerifiedSkillUsers();
      
      setState(() {
        _verifiedUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Skilled Persons',
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
      ),
      body: Column(
        children: [
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
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $_error',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadVerifiedUsers,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _verifiedUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'No verified skilled persons found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadVerifiedUsers,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _verifiedUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _verifiedUsers[index];
                                  final verifiedSkills = List<String>.from(user['verifiedSkills'] ?? []);
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  CachedProfileImage(
                                                    imageUrl: user['userPhotoUrl'],
                                                    size: 48,
                                                    radius: 24,
                                                  ),
                                                  const Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Icon(
                                                      Icons.verified,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          user['userName'] ?? 'Unknown',
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (user['hasVerifiedSkills'] == true)
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
                                                    const SizedBox(height: 4),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: verifiedSkills.map((skill) {
                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.primaryColor.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                skill,
                                                                style: TextStyle(
                                                                  color: AppTheme.primaryColor,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              const Icon(
                                                                Icons.verified,
                                                                color: Colors.blue,
                                                                size: 14,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ViewProfileScreen(
                                                    userId: user['userId'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'View Profile',
                                                    style: TextStyle(
                                                      color: AppTheme.primaryColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    size: 16,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
} 