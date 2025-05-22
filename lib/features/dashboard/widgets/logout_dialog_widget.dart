import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/auth/screens/login_screen.dart';
import 'package:acumen/features/dashboard/utils/loading_dialog.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/theme/app_theme.dart';

class LogoutDialogWidget {
  static Future<void> show(BuildContext context) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirm Logout'),
        message: const Text('Are you sure you want to logout?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context); // Close the action sheet
              
              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    );
                  },
                );

                // Perform logout
                final authController = Provider.of<AuthController>(context, listen: false);
                await authController.signOut();

                // Close loading dialog and navigate to login
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                // Close loading dialog if it's showing
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  AppSnackbar.showError(
                    context: context,
                    message: 'Failed to logout: $e',
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
} 