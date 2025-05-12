import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';

class LogoutDialogWidget {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthController>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 