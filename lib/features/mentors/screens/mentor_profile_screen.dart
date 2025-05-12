import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorProfileScreen extends StatelessWidget {
  final String name;
  final String title;
  final bool hasAvatar;
  
  const MentorProfileScreen({
    super.key,
    required this.name,
    this.title = 'CS Professor',
    this.hasAvatar = true,
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
          Column(
            children: [
              // Upper blue section - shorter to accommodate half the profile image
              SizedBox(height: 80),
              
              // White container
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Space for the bottom half of the profile image
                          const SizedBox(height: 60),
                          
                          Center(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Experience',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildExperienceItem(
                            title: 'Professor',
                            period: '2018-present',
                            organization: 'University of California',
                          ),
                          const SizedBox(height: 16),
                          _buildExperienceItem(
                            title: 'Associate Professor',
                            period: '2013-2018',
                            organization: 'University of California',
                          ),
                          const SizedBox(height: 16),
                          _buildExperienceItem(
                            title: 'Lecturer',
                            period: '2009-2013',
                            organization: 'Stanford University',
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Message',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Profile image positioned to overlap the blue and white sections
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
                child: hasAvatar 
                  ? ClipOval(
                      child: Image.asset('assets/images/profile-img.png',
                      fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem({
    required String title,
    required String period,
    required String organization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$period . $organization',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
} 
