import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentorApplicationsList extends StatelessWidget {
  const MentorApplicationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final applications = userController.pendingTeacherApplications;
        
        if (userController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (applications.isEmpty) {
          return const Center(
            child: Text(
              'No pending mentor applications',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => userController.loadPendingTeacherApplications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mentor = applications[index];
              return _buildMentorApplicationCard(context, mentor, userController);
            },
          ),
        );
      },
    );
  }

  Widget _buildMentorApplicationCard(
    BuildContext context,
    UserModel mentor,
    UserController userController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CachedProfileImage(
                  imageUrl: mentor.photoUrl,
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mentor.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Pending Approval',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusDropdown(context, mentor, userController),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _approveMentor(context, mentor, userController);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _rejectMentor(context, mentor, userController);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    UserModel mentor,
    UserController userController,
  ) {
    String currentStatus = mentor.status ?? 'pending_approval';
    
    return DropdownButton<String>(
      value: currentStatus,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(
        height: 2,
        color: AppTheme.primaryColor,
      ),
      onChanged: (String? newValue) {
        if (newValue != null && newValue != currentStatus) {
          _updateMentorStatus(context, mentor, newValue, userController);
        }
      },
      items: <String>['pending_approval', 'active', 'inactive', 'rejected']
          .map<DropdownMenuItem<String>>((String value) {
        String displayValue;
        switch (value) {
          case 'pending_approval':
            displayValue = 'Pending';
            break;
          case 'active':
            displayValue = 'Active';
            break;
          case 'inactive':
            displayValue = 'Inactive';
            break;
          case 'rejected':
            displayValue = 'Rejected';
            break;
          default:
            displayValue = value;
        }
        
        return DropdownMenuItem<String>(
          value: value,
          child: Text(displayValue),
        );
      }).toList(),
    );
  }

  void _updateMentorStatus(
    BuildContext context,
    UserModel mentor,
    String status,
    UserController userController,
  ) async {
    final result = await userController.updateTeacherStatus(mentor, status);
    
    if (context.mounted) {
      if (result) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Mentor status updated successfully',
        );
      } else {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to update mentor status: ${userController.error}',
        );
      }
    }
  }

  void _approveMentor(
    BuildContext context,
    UserModel mentor,
    UserController userController,
  ) async {
    final result = await userController.approveTeacherAccount(mentor);
    
    if (context.mounted) {
      if (result) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Mentor approved successfully',
        );
      } else {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to approve mentor: ${userController.error}',
        );
      }
    }
  }

  void _rejectMentor(
    BuildContext context,
    UserModel mentor,
    UserController userController,
  ) async {
    final result = await userController.rejectTeacherApplication(mentor);
    
    if (context.mounted) {
      if (result) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Mentor application rejected',
        );
      } else {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to reject mentor application: ${userController.error}',
        );
      }
    }
  }
} 