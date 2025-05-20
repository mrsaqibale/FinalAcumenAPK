import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityMembersBottomSheet extends StatelessWidget {
  final List<String> memberIds;

  const CommunityMembersBottomSheet({
    Key? key,
    required this.memberIds,
  }) : super(key: key);

  static Future<void> show(BuildContext context, List<String> memberIds) async {
    if (memberIds.isEmpty) return;
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final members = await authController.getUsersByIds(memberIds);
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommunityMembersBottomSheet(memberIds: memberIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<AuthController>(context, listen: false).getUsersByIds(memberIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Community Members (${members.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          (member['name'] as String).substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(member['name'] as String),
                      subtitle: Text(member['role'] as String),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 
 
 