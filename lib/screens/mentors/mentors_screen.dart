import 'package:acumen/screens/messaging/chats_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'mentor_profile_screen.dart';

class MentorsScreen extends StatelessWidget {
  const MentorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample mentors data
    final mentors = [
      {
        'name': 'Jacob Wilson',
        'message': 'Thanks for updating',
        'hasAvatar': true,
        'gender': 'male',
        'title': 'CS Professor',
      },
      {
        'name': 'Jhon Smith',
        'message': 'Thanks for updating',
        'hasAvatar': false,
        'gender': 'male',
        'title': 'Mathematics Professor',
      },
      {
        'name': 'Tiffni',
        'message': 'Thanks for updating',
        'hasAvatar': true,
        'gender': 'female',
        'title': 'Biology Professor',
      },
      {
        'name': 'Jenny',
        'message': 'Thanks for updating',
        'hasAvatar': true,
        'gender': 'female',
        'title': 'Physics Professor',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Mentors',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                itemCount: mentors.length,
                itemBuilder: (context, index) {
                  final mentor = mentors[index];
                  return _buildMentorCard(context, mentor);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(BuildContext context, Map<String, dynamic> mentor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MentorProfileScreen(
                  name: mentor['name'],
                  title: mentor['title'],
                  hasAvatar: mentor['hasAvatar'],
                ),
              ),
            );
          },
          child: _buildAvatar(mentor),
        ),
        title: Text(
          mentor['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          mentor['message'],
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatsScreen(initialTabIndex: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> mentor) {
    if (mentor['hasAvatar']) {
      return CircleAvatar(
        backgroundColor: Colors.black,
        radius: 24,
        child: mentor['gender'] == 'female' 
          ? const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            )
          : ClipOval(
              child: Image.asset(
                'assets/images/profile-img.png',
                fit: BoxFit.cover,
              ),
            ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey[400],
        radius: 24,
        child: Text(
          mentor['name'][0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }
} 
