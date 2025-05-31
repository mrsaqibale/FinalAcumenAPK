import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_skill_chip.dart';
import '../widgets/profile_image_widget.dart';
import '../models/skill_model.dart';

class NewUserProfileScreen extends StatelessWidget {
  const NewUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..loadUserData(),
      child: const _NewUserProfileView(),
    );
  }
}

class _NewUserProfileView extends StatelessWidget {
  const _NewUserProfileView();

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
      body: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return Stack(
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
                      child: controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : controller.errorMessage != null
                              ? Center(
                                  child: Text(
                                    controller.errorMessage!,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                )
                              : controller.userData == null
                                  ? const Center(
                                      child: Text(
                                        'No user data found',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    )
                                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Space for the bottom half of the profile image
                          const SizedBox(height: 60),
                          
                          // User name with verification tick
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                                  controller.userData!['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                                                if ((controller.userData!['skills'] as List<SkillModel>).any((skill) => skill.isVerified))
                                Padding(
                                                    padding: const EdgeInsets.only(left: 4.0),
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
                                              controller.userData!['email'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Bio
                          Text(
                                              controller.userData!['bio'],
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
                          
                                            // Skills chips with improved wrapping
                                            Container(
                                              width: double.infinity,
                                              child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                                                alignment: WrapAlignment.start,
                                                children: _buildSkillChips(controller.userData!['skills']),
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
          
          // Profile image positioned to overlap
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
                  child: ProfileImageWidget(
                    topPosition: 0,
                    onCameraTap: () {},
                    imageUrl: controller.profileImageUrl,
              ),
            ),
          ),
        ],
    );
        },
      ),
    );
  }
  
  List<Widget> _buildSkillChips(dynamic skills) {
    if (skills is List<SkillModel>) {
      return skills.map((skill) => ProfileSkillChip(
        skill: skill.name,
        isRemovable: false,
        isVerified: skill.isVerified,
      )).toList();
    } else if (skills is List) {
      return skills.map((skill) {
        if (skill is SkillModel) {
          return ProfileSkillChip(
            skill: skill.name,
            isRemovable: false,
            isVerified: skill.isVerified,
          );
        } else {
          return ProfileSkillChip(
            skill: skill.toString(),
            isRemovable: false,
            isVerified: false,
          );
        }
      }).toList();
    }
    return [];
  }
} 
