import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class NewUserProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String bio;
  final List<String> skills;
  final String imageUrl;

  const NewUserProfileScreen({
    super.key,
    this.name = 'Jacob willson',
    this.email = 'jacobwillson@gmail.com',
    this.bio = 'Aspiring software developer with a passion for learning and creating innovative solutions',
    this.skills = const ['python', 'Java', 'SQL'],
    this.imageUrl = 'assets/images/profile-img.png',
  });

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
      body: Stack(
        children: [
          // Main layout
          Column(
            children: [
              // Blue section - shorter to accommodate half the profile image
              const SizedBox(height: 80),
              
              // White container with details
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Space for the bottom half of the profile image
                          const SizedBox(height: 60),
                          
                          // User name
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                          
                          // Skills chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: skills.map((skill) => _buildSkillChip(skill)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Profile image positioned to overlap
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(128)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
} 
