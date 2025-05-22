import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorCard extends StatelessWidget {
  final UserModel mentor;
  final Function(UserModel, bool) onActiveStatusChanged;
  final Function(UserModel, bool) onApprovalStatusChanged;
  final Function(UserModel) onDelete;

  const MentorCard({
    super.key,
    required this.mentor,
    required this.onActiveStatusChanged,
    required this.onApprovalStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                _buildMentorAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mentor.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _showDeleteConfirmationDialog(context),
                            tooltip: 'Delete Mentor',
                          ),
                        ],
                      ),
                      Text(
                        mentor.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (mentor.employeeId != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${mentor.employeeId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mentor.isApproved == true 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              mentor.isApproved == true ? 'Approved' : 'Pending Approval',
                              style: TextStyle(
                                color: mentor.isApproved == true ? Colors.green : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showApprovalToggleDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    mentor.isApproved == true ? Icons.check_circle : Icons.pending,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Change Status',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: mentor.isActive,
                      onChanged: (value) => onActiveStatusChanged(mentor, value),
                      activeColor: Colors.white,
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(
                      mentor.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: mentor.isActive ? AppTheme.primaryColor : Colors.grey,
                      ),
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

  Widget _buildMentorAvatar() {
    return CachedProfileImage(
      imageUrl: mentor.photoUrl,
      size: 40,
      radius: 20,
      backgroundColor: mentor.photoUrl == null 
          ? AppTheme.primaryColor.withOpacity(0.2)
          : Colors.white,
      placeholderIcon: FontAwesomeIcons.user,
      placeholderSize: 20,
      placeholderColor: AppTheme.primaryColor,
    );
  }

  void _showApprovalToggleDialog(BuildContext context) {
    final isCurrentlyApproved = mentor.isApproved == true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentlyApproved ? 'Revoke Approval?' : 'Approve Mentor?'),
        content: Text(
          isCurrentlyApproved
              ? 'Are you sure you want to revoke ${mentor.name}\'s mentor approval? This will prevent them from accessing mentor features.'
              : 'Are you sure you want to approve ${mentor.name} as a mentor? This will grant them access to mentor features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onApprovalStatusChanged(mentor, !isCurrentlyApproved);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCurrentlyApproved
                        ? '${mentor.name}\'s mentor approval has been revoked'
                        : '${mentor.name} has been approved as a mentor',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isCurrentlyApproved ? Colors.red : Colors.green,
            ),
            child: Text(isCurrentlyApproved ? 'REVOKE' : 'APPROVE'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mentor'),
        content: Text(
          'Are you sure you want to delete ${mentor.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(mentor);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${mentor.name} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
} 