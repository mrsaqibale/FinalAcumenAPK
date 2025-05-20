import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/repositories/user_repository.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorProfileScreen extends StatefulWidget {
  final String mentorId;

  const MentorProfileScreen({
    Key? key,
    required this.mentorId,
  }) : super(key: key);

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  UserModel? _mentor;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMentorData();
  }

  Future<void> _loadMentorData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mentor = await _userRepository.getUserById(widget.mentorId);
      setState(() {
        _mentor = mentor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load mentor data: $e';
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
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
              : _mentor == null
                  ? const Center(child: Text('Mentor not found', style: TextStyle(color: Colors.white)))
                  : !_mentor!.isActive
                      ? _buildInactiveUserMessage()
                      : _buildMentorProfile(),
    );
  }

  Widget _buildInactiveUserMessage() {
    return Column(
      children: [
        const SizedBox(height: 40),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  "This user's profile is not available",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "The user account has been deactivated by an administrator.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMentorProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedProfileImage(
            imageUrl: _mentor!.photoUrl,
            size: 120,
            radius: 60,
            placeholderIcon: FontAwesomeIcons.user,
            placeholderSize: 60,
            placeholderColor: AppTheme.primaryColor,
            backgroundColor: Colors.grey[200]!,
          ),
          const SizedBox(height: 20),
          Text(
            _mentor!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _mentor!.title ?? 'Mentor',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildContactButton(),
          const SizedBox(height: 30),
          _buildInfoCard('Email', _mentor!.email, Icons.email),
          const SizedBox(height: 10),
          if (_mentor!.role == 'teacher')
            _buildInfoCard('Role', 'Mentor (Teacher)', Icons.school)
          else
            _buildInfoCard('Role', 'Mentor', Icons.person),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to chat with this mentor
        // You can implement this later
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat feature coming soon')),
        );
      },
      icon: const Icon(Icons.chat),
      label: const Text('Start Chat'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
