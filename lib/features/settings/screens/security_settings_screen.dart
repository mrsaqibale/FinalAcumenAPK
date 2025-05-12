import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _passwordLessLogin = false;
  bool _sessionTimeout = true;
  final int _sessionTimeoutMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Security Settings',
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
                  _buildSectionTitle('Authentication Options'),
                  _buildSwitchTile(
                    title: 'Enable Biometric Login',
                    subtitle: 'Use fingerprint or face ID to log in',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.fingerprint,
                  ),
                  _buildSwitchTile(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Receive a verification code via email or SMS',
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.shieldHalved,
                  ),
                  _buildSwitchTile(
                    title: 'Passwordless Login',
                    subtitle: 'Login using email magic links',
                    value: _passwordLessLogin,
                    onChanged: (value) {
                      setState(() {
                        _passwordLessLogin = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.link,
                  ),
                  const Divider(),
                  _buildSectionTitle('Session Management'),
                  _buildSwitchTile(
                    title: 'Auto Logout',
                    subtitle: 'Automatically logout after $_sessionTimeoutMinutes minutes of inactivity',
                    value: _sessionTimeout,
                    onChanged: (value) {
                      setState(() {
                        _sessionTimeout = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.clock,
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FontAwesomeIcons.globe,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: const Text('Active Sessions'),
                    subtitle: const Text('Manage devices where you\'re logged in'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to active sessions screen
                    },
                  ),
                  const Divider(),
                  _buildSectionTitle('Password & Recovery'),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FontAwesomeIcons.key,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to change password screen
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FontAwesomeIcons.envelope,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: const Text('Recovery Email'),
                    subtitle: const Text('Manage your recovery options'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to recovery options screen
                    },
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Show sign out from all devices dialog
                      _showSignOutAllDevicesDialog();
                    },
                    child: Text(
                      'Sign Out From All Devices',
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

  void _showSignOutAllDevicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sign Out From All Devices"),
          content: const Text(
            "This will sign you out from all devices where you're currently logged in. You'll need to sign in again on each device.",
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
                "Sign Out All",
                style: TextStyle(color: Colors.red[400]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Implement sign out functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out from all devices.'),
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
