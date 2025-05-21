import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';

class StudentListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final bool isLoading;
  final Function(Map<String, dynamic>) onCreateChat;
  final VoidCallback onRefresh;

  const StudentListWidget({
    super.key,
    required this.students,
    required this.isLoading,
    required this.onCreateChat,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              student['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(student['name'] ?? 'Unknown'),
          subtitle: Text(student['rollNumber'] != null && student['rollNumber'].toString().isNotEmpty 
              ? 'Roll: ${student['rollNumber']}' 
              : student['email'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.message, color: AppTheme.primaryColor),
            onPressed: () => onCreateChat(student),
          ),
          onTap: () => onCreateChat(student),
        );
      },
    );
  }
} 