import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/features/profile/models/skill_model.dart';
import 'profile_image_viewer_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String bio;
  final List<dynamic> skills; // Can be List<String> or List<SkillModel>
  final String imageUrl;
  final bool isVerified;

  const UserProfileScreen({
    super.key,
    this.name = 'imtiaz willson',
    this.email = 'jacobwillson@gmail.com',
    this.bio = 'Aspiring software developer with a passion for learning and creating innovative solutions',
    this.skills = const ['python', 'Java', 'SQL'],
    this.imageUrl = 'assets/images/profile-img.png',
    this.isVerified = false,
  });

  bool get _hasVerifiedSkills {
    if (skills.isEmpty) return false;
    
    for (var skill in skills) {
      if (skill is SkillModel && skill.isVerified) {
        return true;
      }
    }
    return false;
  }

  void _handleImageTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileImageViewerScreen(
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Profile image section (centered on the blue/white border)
          SizedBox(
            height: 110,
            child: Center(
              child: CachedProfileImage(
                imageUrl: imageUrl,
                size: 120,
                onTap: () => _handleImageTap(context),
              ),
            ),
          ),
          
          // White section with user details
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Space for the overlapping image
                  
                  // User name with verification icon if verified
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasVerifiedSkills || isVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            FontAwesomeIcons.solidCircleCheck,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  
                  // Email
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bio
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Divider
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.withAlpha(77),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Skills section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Skills chips or empty state
                  if (skills.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No skills added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skills.map((skill) {
                        // Handle both String and SkillModel types
                        if (skill is String) {
                          return _buildSkillChip(skill, false);
                        } else if (skill is SkillModel) {
                          return _buildSkillChip(skill.name, skill.isVerified);
                        }
                        return _buildSkillChip(skill.toString(), false);
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(128)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVerified)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: Colors.blue,
                size: 14,
              ),
            ),
          Flexible(
      child: Text(
        skill,
              overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
            ),
          ),
        ],
      ),
    );
  }
} 
