import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/features/profile/screens/user_profile_screen.dart';
import 'package:acumen/features/profile/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showVerification;
  final EdgeInsets padding;
  final bool showEmail;
  final bool navigateToProfile;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.showVerification = true,
    this.padding = const EdgeInsets.all(12),
    this.showEmail = true,
    this.navigateToProfile = true,
  });

  bool get isVerified => user.hasVerifiedSkills ?? false;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (navigateToProfile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(
            name: user.name,
            email: user.email,
            imageUrl: user.photoUrl ?? '',
            bio: user.education?['bio'] ?? 'No bio available',
            skills: user.skills ?? [],
            isVerified: user.hasVerifiedSkills ?? false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // Profile Image
              CachedProfileImage(
                imageUrl: user.photoUrl ?? '',
                size: 50,
              ),
              
              const SizedBox(width: 12),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name with verification badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showVerification && isVerified)
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
                    
                    if (showEmail && user.email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action Icon
              if (onTap != null)
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
} 