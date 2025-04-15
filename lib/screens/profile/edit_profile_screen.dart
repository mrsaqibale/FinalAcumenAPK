import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String bio;
  final List<String> skills;
  final String imageUrl;

  const EditProfileScreen({
    super.key,
    this.name = 'Jacob willson',
    this.email = 'Jacobwillson@gmail.com',
    this.bio = 'Aspiring software developer with a passion for learning and creating innovative solutions',
    this.skills = const ['python', 'Java', 'SQL'],
    this.imageUrl = 'assets/images/profile-img.png',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  late List<String> userSkills;
  final ScrollController _scrollController = ScrollController();
  double _profileImageTop = 30;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    bioController = TextEditingController(text: widget.bio);
    emailController = TextEditingController(text: widget.email);
    userSkills = List.from(widget.skills);

    // Add scroll listener to move profile image up when scrolling
    _scrollController.addListener(() {
      setState(() {
        // Calculate the new top position based on scroll
        // Start moving at 0 and move up to a max of 30px
        _profileImageTop = 30 - (_scrollController.offset * 0.15).clamp(0, 20);
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A3B), // Dark navy blue from the screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF001A3B),
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
          // White background starting below appbar
          Column(
            children: [
              const SizedBox(height: 80), // Space for profile image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F8F8), // Light gray background from screenshot
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // Extra top padding for image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditField(
                            controller: nameController,
                            hintText: 'Enter your name',
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Bio field
                          const Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditField(
                            controller: bioController,
                            hintText: 'Tell us about yourself',
                            maxLines: 3,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Skills section
                          const Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: userSkills.map((skill) => _buildSkillChip(skill)).toList(),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Email field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditField(
                            controller: emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Save button
                          Center(
                            child: Container(
                              width: 200,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFF001A3B),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextButton(
                                onPressed: _saveProfile,
                                child: const Text(
                                  'Save',
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
          
          // Profile image positioned to overlap
          AnimatedPositioned(
            duration: const Duration(milliseconds: 0), // Instant movement
            top: _profileImageTop,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
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
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Camera icon for changing profile picture
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          suffixIcon: const Icon(
            Icons.edit,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(77)),
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

  void _saveProfile() {
    // Here you would save the profile data to your backend or local storage
    // For now, we'll just simulate success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }
} 
