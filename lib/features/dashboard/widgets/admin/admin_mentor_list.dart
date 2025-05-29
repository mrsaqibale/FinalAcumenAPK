import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/dashboard/controllers/mentor_controller.dart';
import 'package:acumen/features/dashboard/widgets/admin/mentor_card.dart';
import 'package:provider/provider.dart';

class AdminMentorList extends StatefulWidget {
  final UserController userController;

  const AdminMentorList({super.key, required this.userController});

  @override
  State<AdminMentorList> createState() => _AdminMentorListState();
}

class _AdminMentorListState extends State<AdminMentorList> {
  late MentorController _mentorController;

  @override
  void initState() {
    super.initState();
    _mentorController = MentorController(userController: widget.userController);
  }

  Future<void> _handleDeleteMentor(UserModel mentor) async {
    final success = await _mentorController.deleteMentor(mentor);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${mentor.name} has been deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete mentor. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mentorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mentorController,
      child: Consumer<MentorController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or employee ID',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                    ),
                    suffixIcon:
                        controller.searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: controller.clearSearch,
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Mentor list
              Expanded(
                child:
                    controller.filteredMentors.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.searchQuery.isEmpty
                                    ? 'No mentors found'
                                    : 'No mentors found matching "${controller.searchQuery}"',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: controller.refreshMentors,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.filteredMentors.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final mentor = controller.filteredMentors[index];
                              return MentorCard(
                                mentor: mentor,
                                onActiveStatusChanged:
                                    controller.updateMentorActiveStatus,
                                onApprovalStatusChanged:
                                    controller.updateMentorApprovalStatus,
                                onDelete: _handleDeleteMentor,
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
