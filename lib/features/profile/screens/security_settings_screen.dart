import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acumen/features/auth/screens/create_new_password_screen.dart';
import 'package:acumen/services/session_timeout_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _sessionTimeout = false;
  final int _sessionTimeoutMinutes = 30;
  static const String _timeoutKey = 'session_timeout_enabled';

  @override
  void initState() {
    super.initState();
    _loadSessionTimeout();
  }

  Future<void> _loadSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessionTimeout = prefs.getBool(_timeoutKey) ?? false;
    });
  }

  Future<void> _toggleSessionTimeout(bool value) async {
    setState(() {
      _sessionTimeout = value;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timeoutKey, value);
    
    if (value) {
      // Start session monitoring if enabled
      SessionTimeoutService.startMonitoring(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto logout after $_sessionTimeoutMinutes minutes enabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Stop the timeout monitoring
      SessionTimeoutService.dispose();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto logout disabled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
                  _buildSectionTitle('Session Management'),
                  _buildSwitchTile(
                    title: 'Auto Logout',
                    subtitle: 'Automatically logout after $_sessionTimeoutMinutes minutes of inactivity',
                    value: _sessionTimeout,
                    onChanged: _toggleSessionTimeout,
                    leadingIcon: FontAwesomeIcons.clock,
                  ),
                  const Divider(),
                  // _buildSectionTitle('Password'),
                  // ListTile(
                  //   leading: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.primaryColor.withAlpha(26),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Icon(
                  //       FontAwesomeIcons.key,
                  //       color: AppTheme.primaryColor,
                  //       size: 20,
                  //     ),
                  //   ),
                  //   title: const Text('Change Password'),
                  //   subtitle: const Text('Update your account password'),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const CreateNewPasswordScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                 
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
                // Sign out from all devices
                _signOutFromAllDevices();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _signOutFromAllDevices() async {
    try {
      // Clear local auth token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      // Here you would implement the API call to invalidate all sessions
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out from all devices.'),
        ),
      );
      
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 
