import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PreferencesSettingsScreen extends StatefulWidget {
  const PreferencesSettingsScreen({super.key});

  @override
  State<PreferencesSettingsScreen> createState() => _PreferencesSettingsScreenState();
}

class _PreferencesSettingsScreenState extends State<PreferencesSettingsScreen> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _reminderNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedTimeZone = 'UTC (Coordinated Universal Time)';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedTimeFormat = '12-hour';
  
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Arabic',
    'Russian',
  ];
  
  final List<String> _timeZones = [
    'UTC (Coordinated Universal Time)',
    'GMT (Greenwich Mean Time)',
    'EST (Eastern Standard Time)',
    'CST (Central Standard Time)',
    'MST (Mountain Standard Time)',
    'PST (Pacific Standard Time)',
    'IST (Indian Standard Time)',
    'JST (Japan Standard Time)',
  ];
  
  final List<String> _dateFormats = [
    'MM/DD/YYYY',
    'DD/MM/YYYY',
    'YYYY/MM/DD',
    'MM-DD-YYYY',
    'DD-MM-YYYY',
    'YYYY-MM-DD',
  ];
  
  final List<String> _timeFormats = [
    '12-hour',
    '24-hour',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Preferences',
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
                  _buildSectionTitle('Theme'),
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme for the app',
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.moon,
                  ),
                  const Divider(),
                  _buildSectionTitle('Notifications'),
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.bell,
                  ),
                  _buildSwitchTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive email notifications',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.envelope,
                  ),
                  _buildSwitchTile(
                    title: 'Reminders',
                    subtitle: 'Receive reminders for events and deadlines',
                    value: _reminderNotifications,
                    onChanged: (value) {
                      setState(() {
                        _reminderNotifications = value;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.clock,
                  ),
                  const Divider(),
                  _buildSectionTitle('Language & Region'),
                  _buildDropdownTile(
                    title: 'Language',
                    subtitle: 'Select your preferred language',
                    value: _selectedLanguage,
                    items: _languages,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                    leadingIcon: FontAwesomeIcons.globe,
                  ),
                  _buildDropdownTile(
                    title: 'Time Zone',
                    subtitle: 'Select your time zone',
                    value: _selectedTimeZone,
                    items: _timeZones,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTimeZone = value;
                        });
                      }
                    },
                    leadingIcon: FontAwesomeIcons.earthAmericas,
                  ),
                  const Divider(),
                  _buildSectionTitle('Format'),
                  _buildDropdownTile(
                    title: 'Date Format',
                    subtitle: 'Select how dates are displayed',
                    value: _selectedDateFormat,
                    items: _dateFormats,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDateFormat = value;
                        });
                      }
                    },
                    leadingIcon: FontAwesomeIcons.calendar,
                  ),
                  _buildDropdownTile(
                    title: 'Time Format',
                    subtitle: 'Select how time is displayed',
                    value: _selectedTimeFormat,
                    items: _timeFormats,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTimeFormat = value;
                        });
                      }
                    },
                    leadingIcon: FontAwesomeIcons.clock,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _showResetDialog();
                    },
                    child: const Text(
                      'Reset All Preferences',
                      style: TextStyle(color: AppTheme.primaryColor),
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

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData leadingIcon,
  }) {
    return ListTile(
      leading: Container(
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
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Preferences"),
          content: const Text(
            "This will reset all your preferences to default settings. Are you sure you want to continue?",
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
                "Reset",
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Reset preferences to default
                setState(() {
                  _darkMode = false;
                  _pushNotifications = true;
                  _emailNotifications = true;
                  _reminderNotifications = true;
                  _selectedLanguage = 'English';
                  _selectedTimeZone = 'UTC (Coordinated Universal Time)';
                  _selectedDateFormat = 'MM/DD/YYYY';
                  _selectedTimeFormat = '12-hour';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All preferences have been reset to default.'),
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
