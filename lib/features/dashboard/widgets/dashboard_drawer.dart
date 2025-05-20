import 'package:acumen/features/auth/screens/login_screen.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/notification/screens/notifications_screen.dart';
import 'package:acumen/features/profile/screens/edit_profile_screen.dart';
import 'package:acumen/features/profile/screens/mentors_screen.dart';
import 'package:acumen/features/profile/screens/new_user_profile_screen.dart';
import 'package:acumen/features/profile/screens/settings_screen.dart';
import 'package:acumen/features/dashboard/utils/dashboard_utils.dart';
import 'package:acumen/features/dashboard/utils/loading_dialog.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardDrawer extends StatelessWidget {
  final String username;

  const DashboardDrawer({
    super.key,
    required this.username,
  });

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final authController = AuthController();
    
    showCupertinoModalPopup(
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
                // Show loading dialog and perform logout
                await LoadingDialog.showWhile(
                  context,
                  () async {
                await authController.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
                  },
                );
              } catch (e) {
                if (context.mounted) {
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
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final name = userData?['name'] as String? ?? username;
              final email = FirebaseAuth.instance.currentUser?.email ?? '';
              final profileImageUrl = userData?['profileImageUrl'] as String?;

              return UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
                currentAccountPicture: CachedProfileImage(
                  imageUrl: profileImageUrl,
                  size: 72,
                  radius: 36,
              backgroundColor: Colors.white,
            ),
            accountName: Text(
                  DashboardUtils.capitalizeName(name),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
              );
            },
          ),
          Expanded(
            child: ListView(
              children: [
          ListTile(
            leading: const Icon(FontAwesomeIcons.house, color: AppTheme.primaryColor, size: 20),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
                  leading: Image.asset('assets/images/icons/user.png', color: Colors.black, height: 40, width: 20),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewUserProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.userPen, color: AppTheme.primaryColor, size: 20),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(
                    const AssetImage('assets/images/icons/bell.png'),
              color: AppTheme.primaryColor,
              size: 22,
            ),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.solidMessage, color: AppTheme.primaryColor, size: 20),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MentorsScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.gear, color: AppTheme.primaryColor, size: 20),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.red, size: 20),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
                    Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
          ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
} 