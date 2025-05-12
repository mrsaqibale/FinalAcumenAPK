import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/chat/new_community_dialog_widget.dart';

class DashboardFabWidget extends StatelessWidget {
  final int currentTabIndex;
  final VoidCallback onCreateAssignment;

  const DashboardFabWidget({
    Key? key,
    required this.currentTabIndex,
    required this.onCreateAssignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (currentTabIndex) {
      case 0: // Communities
        return FloatingActionButton(
          onPressed: () {
            // Using the compatibility method which now navigates to the screen
            NewCommunityDialogWidget.show(context);
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        );
      case 1: // Assignments
        return FloatingActionButton(
          onPressed: onCreateAssignment,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.assignment_add),
        );
      default:
        return const SizedBox.shrink();
    }
  }
} 