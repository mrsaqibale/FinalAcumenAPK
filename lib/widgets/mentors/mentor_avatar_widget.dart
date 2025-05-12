import 'package:acumen/features/mentors/models/mentor_model.dart';
import 'package:flutter/material.dart';

class MentorAvatarWidget extends StatelessWidget {
  final Mentor mentor;

  const MentorAvatarWidget({
    super.key,
    required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
    if (mentor.hasAvatar) {
      return CircleAvatar(
        backgroundColor: Colors.black,
        radius: 24,
        child: mentor.gender == 'female' 
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
          mentor.name[0].toUpperCase(),
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