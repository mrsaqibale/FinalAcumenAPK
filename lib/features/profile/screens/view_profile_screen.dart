import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/features/profile/repositories/profile_repository.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/skill_model.dart';

class ViewProfileScreen extends StatefulWidget {
  final String userId;

  const ViewProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final _profileRepository = ProfileRepository();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = await _profileRepository.loadUserDataById(widget.userId);
      final imageUrl = await _profileRepository.getProfileImageUrlById(widget.userId);

      setState(() {
        _userData = userData;
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : _userData == null
                  ? const Center(
                      child: Text(
                        'User not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 80),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _userData!['name'],
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if ((_userData!['skills'] as List<SkillModel>).any((skill) => skill.isVerified)) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                FontAwesomeIcons.solidCircleCheck,
                                                size: 14,
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Email
                                      Center(
                                        child: Text(
                                          _userData!['email'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Bio
                                      const Text(
                                        'Bio',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _userData!['bio'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Skills
                                      const Text(
                                        'Skills',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (var skill in _userData!['skills'] as List<SkillModel>)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: skill.isVerified
                                                    ? AppColors.primary.withOpacity(0.1)
                                                    : Colors.grey[200],
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      skill.name,
                                                      style: TextStyle(
                                                        color: skill.isVerified
                                                            ? AppColors.primary
                                                            : Colors.grey[800],
                                                      ),
                                                    ),
                                                  ),
                                                  if (skill.isVerified) ...[
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      FontAwesomeIcons.solidCircleCheck,
                                                      size: 14,
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Profile image
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CachedProfileImage(
                              imageUrl: _profileImageUrl,
                              size: 120,
                              radius: 60,
                              placeholderIcon: FontAwesomeIcons.user,
                              placeholderSize: 60,
                              placeholderColor: AppColors.primary,
                              backgroundColor: Colors.grey[200]!,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
} 