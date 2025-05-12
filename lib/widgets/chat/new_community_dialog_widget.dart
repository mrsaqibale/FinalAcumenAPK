import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewCommunityScreen extends StatefulWidget {
  const NewCommunityScreen({Key? key}) : super(key: key);

  @override
  State<NewCommunityScreen> createState() => _NewCommunityScreenState();
}

class _NewCommunityScreenState extends State<NewCommunityScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> selectedUsers = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Check if user is a mentor
    if (!chatController.isMentor(context)) {
      AppSnackbar.showError(
        context: context,
        message: 'Only mentors can create communities',
      );
      Navigator.pop(context);
      return;
    }
    
    // Get only students
    students = await authController.getStudents();
    
    // Also load recent students for quick access
    await chatController.loadRecentStudents();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Create New Community',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Community Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    
                    // Recent students section
                    Consumer<ChatController>(
                      builder: (context, chatController, child) {
                        final recentStudents = chatController.recentStudents;
                        if (recentStudents.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'New Students:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (recentStudents.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        // Select all recent students
                                        for (var student in recentStudents) {
                                          final id = student['id'] as String;
                                          if (!selectedUsers.contains(id)) {
                                            selectedUsers.add(id);
                                          }
                                        }
                                      });
                                    },
                                    child: const Text('Select All'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentStudents.length,
                                itemBuilder: (context, index) {
                                  final student = recentStudents[index];
                                  // Skip if not a student
                                  if (student['role'] != 'student') {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  final id = student['id'] as String;
                                  final isSelected = selectedUsers.contains(id);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedUsers.remove(id);
                                        } else {
                                          selectedUsers.add(id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 80,
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: isSelected
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey.shade200,
                                                child: Text(
                                                  (student['name'] as String).substring(0, 1).toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 2),
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            student['name'] as String,
                                            style: const TextStyle(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            student['rollNumber'] as String,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'All Students:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        // Skip if not a student
                        if (student['role'] != 'student') {
                          return const SizedBox.shrink();
                        }
                        
                        final userId = student['id'] as String;
                        final isSelected = selectedUsers.contains(userId);
                        
                        return CheckboxListTile(
                          title: Text(student['name'] ?? 'Unknown'),
                          subtitle: Text(student['rollNumber'] ?? student['email'] ?? ''),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedUsers.add(userId);
                              } else {
                                selectedUsers.remove(userId);
                              }
                            });
                          },
                          secondary: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade200,
                            child: Text(
                              (student['name'] as String).substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Selected: ${selectedUsers.length} students',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'Please enter a community name',
                    );
                    return;
                  }
                  
                  if (selectedUsers.isEmpty) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'Please select at least one student',
                    );
                    return;
                  }
                  
                  setState(() {
                    _isLoading = true;
                  });
                  
                  // Create the community
                  final chatController = Provider.of<ChatController>(context, listen: false);
                  final success = await chatController.createCommunity(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    memberIds: selectedUsers,
                  );
                  
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    AppSnackbar.showSuccess(
                      context: context,
                      message: 'Community created successfully',
                    );
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Text('Create Community'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep this for backward compatibility until all references are updated
class NewCommunityDialogWidget {
  static Future<void> show(BuildContext context) async {
    final chatController = Provider.of<ChatController>(context, listen: false);
    
    // Check if user is a mentor
    if (!chatController.isMentor(context)) {
      AppSnackbar.showError(
        context: context,
        message: 'Only mentors can create communities',
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCommunityScreen()),
    );
  }
} 