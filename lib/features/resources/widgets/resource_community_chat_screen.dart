import 'package:flutter/material.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/resources/widgets/resource_community_chat_list.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ResourceCommunityChatScreen extends StatelessWidget {
  final String communityId;
  final String communityName;
  final List<String> memberIds;
  final String? imageUrl;

  const ResourceCommunityChatScreen({
    Key? key,
    required this.communityId,
    required this.communityName,
    required this.memberIds,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final currentUserId = authController.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              communityName,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${memberIds.length} members',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show community info
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider<MessageController>(
        create: (_) => MessageController(),
        child: ResourceCommunityChatList(
          communityId: communityId,
          currentUserId: currentUserId,
          scrollController: ScrollController(),
          onDeleteMessage: (_) {}, // Empty function for message deletion
          onReplyToMessage: (_, __) {}, // Empty function for reply
          onForwardMessage: (_) {}, // Empty function for forward
        ),
      ),
    );
  }
} 