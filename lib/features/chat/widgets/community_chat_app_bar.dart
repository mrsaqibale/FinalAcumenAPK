import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String communityName;
  final String? imageUrl;
  final List<String>? memberIds;
  final VoidCallback onMembersPressed;

  const CommunityChatAppBar({
    Key? key,
    required this.communityName,
    this.imageUrl,
    this.memberIds,
    required this.onMembersPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(imageUrl!),
            )
          else
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                communityName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  communityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (memberIds != null)
                  Text(
                    '${memberIds!.length} members',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.group, color: Colors.white),
          onPressed: onMembersPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 
 
 