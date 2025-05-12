import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/theme/app_theme.dart';

class MembersDialogWidget {
  static Future<void> show(BuildContext context, Map<String, dynamic> community) async {
    final members = await Provider.of<AuthController>(context, listen: false).getUsersByIds(
      (community['members'] as List<dynamic>).cast<String>(),
    );
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${community["name"]} Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: member['role'] == 'mentor' 
                      ? AppTheme.primaryColor 
                      : Colors.grey.shade200,
                  child: Text(
                    (member['name'] as String).substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: member['role'] == 'mentor' ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                title: Text(member['name'] as String),
                subtitle: Text(
                  member['role'] == 'mentor' 
                      ? 'Mentor' 
                      : member['rollNumber'] as String? ?? 'Student',
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 