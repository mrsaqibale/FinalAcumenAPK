import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'security_settings_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Notifications toggle
              _buildToggleItem(
                title: 'Notifications',
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Security option
              _buildNavigationItem(
                title: 'Security',
                onTap: () {
                   Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen(),
                        ),
                      );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Privacy option
              _buildNavigationItem(
                title: 'Privacy',
                onTap: () {
                   Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const PrivacySettingsScreen(),
                        ),
                      );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Preferences option
              _buildNavigationItem(
                title: 'Preferences',
                onTap: () {
                  Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen(),
                        ),
                      
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppTheme.primaryColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
