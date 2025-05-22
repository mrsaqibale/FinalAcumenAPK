import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // _buildSectionTitle('Profile Privacy'),
                  // _buildSwitchTile(
                  //   title: 'Public Profile',
                  //   subtitle: 'Make your profile visible to everyone',
                  //   value: _profileVisibility,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _profileVisibility = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.userLarge,
                  // ),
                  // _buildSwitchTile(
                  //   title: 'Show Online Status',
                  //   subtitle: 'Allow others to see when you\'re online',
                  //   value: _showOnlineStatus,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _showOnlineStatus = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.circleCheck,
                  // ),
                  // ListTile(
                  //   leading: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.primaryColor.withAlpha(26),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Icon(
                  //       FontAwesomeIcons.eyeSlash,
                  //       color: AppTheme.primaryColor,
                  //       size: 20,
                  //     ),
                  //   ),
                  //   title: const Text('Blocked Users'),
                  //   subtitle: const Text('Manage people you\'ve blocked'),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     // Navigate to blocked users screen
                  //   },
                  // ),
                  // const Divider(),
                  // _buildSectionTitle('Interactions'),
                  // _buildSwitchTile(
                  //   title: 'Allow Messages',
                  //   subtitle: 'Receive messages from other users',
                  //   value: _allowMessages,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _allowMessages = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.comment,
                  // ),
                  // _buildSwitchTile(
                  //   title: 'Allow Tagging',
                  //   subtitle: 'Let others tag you in posts and comments',
                  //   value: _allowTagging,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _allowTagging = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.tag,
                  // ),
                  // const Divider(),
                  // _buildSectionTitle('Data & Permissions'),
                  // _buildSwitchTile(
                  //   title: 'Usage Data Collection',
                  //   subtitle: 'Allow us to collect anonymous usage data',
                  //   value: _dataCollection,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _dataCollection = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.chartPie,
                  // ),
                  // _buildSwitchTile(
                  //   title: 'Location Tracking',
                  //   subtitle: 'Allow app to access your location',
                  //   value: _locationTracking,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _locationTracking = value;
                  //     });
                  //   },
                  //   leadingIcon: FontAwesomeIcons.locationDot,
                  // ),
                  // ListTile(
                  //   leading: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.primaryColor.withAlpha(26),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Icon(
                  //       FontAwesomeIcons.fileArrowDown,
                  //       color: AppTheme.primaryColor,
                  //       size: 20,
                  //     ),
                  //   ),
                  //   title: const Text('Download My Data'),
                  //   subtitle: const Text('Get a copy of your personal data'),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     _showDownloadDataDialog();
                  //   },
                  // ),
                  // const SizedBox(height: 20),
                  // TextButton(
                  //   style: TextButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(vertical: 15),
                  //   ),
                  //   onPressed: () {
                  //     // Navigate to privacy policy
                  //   },
                  //   child: const Text(
                  //     'View Privacy Policy',
                  //     style: TextStyle(color: AppTheme.primaryColor),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Delete My Account',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData leadingIcon,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          leadingIcon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Download Your Data"),
          content: const Text(
            "We'll prepare a file with your personal data. This may take some time. We'll notify you when it's ready to download.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Request Data",
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Implement data download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your data request has been submitted. We\'ll notify you when it\'s ready.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.userXmark,
                          size: 40,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Delete Your Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Warning: This action permanently removes all your data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'When you delete your account:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildBulletPoint('All your profile information will be deleted'),
                    _buildBulletPoint('You will be removed from all communities'),
                    _buildBulletPoint('All your messages and chat history will be erased'),
                    _buildBulletPoint('Your membership data will be permanently removed'),
                    _buildBulletPoint('All notifications related to your account will be cleared'),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        _showDeleteAccountDialog(context);
                      },
                      child: Text(
                        'Delete My Account',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.red[400],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Your Account"),
          content: const Text(
            "This action cannot be undone. All your data including profile, communities, memberships, chats, and notifications will be permanently deleted. Are you sure you want to proceed?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete Account",
                style: TextStyle(color: Colors.red[400]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Perform Firebase deletion
                _deleteUserAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUserAccount(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Deleting your account..."),
              ],
            ),
          );
        },
      );
      
      // TODO: Implement Firebase Auth and Firestore deletion
      // 1. Delete user data from Firestore (profile, communities, messages)
      // await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      // 
      // 2. Delete user authentication
      // await FirebaseAuth.instance.currentUser?.delete();

      // Simulate deletion process
      await Future.delayed(const Duration(seconds: 2));
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion completed. Your account and all associated data have been removed.'),
        ),
      );
      
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 
