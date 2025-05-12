import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';

class StudentsTabWidget extends StatelessWidget {
  const StudentsTabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<AuthController>(context, listen: false).getStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return const Center(
            child: Text('No students found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    (student['name'] as String).substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(student['name'] as String),
                subtitle: Text(student['rollNumber'] as String),
                trailing: IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () => _startDirectChat(context, student),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startDirectChat(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Chat'),
        content: Text('Start a direct chat with ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final chatController = Provider.of<ChatController>(context, listen: false);
                final conversation = await chatController.createConversation(
                  participantId: student['id'] as String,
                  participantName: student['name'] as String,
                  participantImageUrl: null,
                );
                
                if (context.mounted) {
                  AppSnackbar.showSuccess(
                    context: context,
                    message: 'Chat created successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(
                    context: context,
                    message: 'Failed to create chat: $e',
                  );
                }
              }
            },
            child: const Text('START CHAT'),
          ),
        ],
      ),
    );
  }
} 