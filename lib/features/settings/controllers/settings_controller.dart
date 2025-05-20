import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String? _error;
  static const String _notificationsKey = 'notifications_enabled';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SettingsController() {
    _loadSettings();
  }

  // Add static method to check notification status from anywhere
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> _loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
      notifyListeners();
    }
  }

  Future<void> toggleNotifications(bool value) async {
    try {
      _notificationsEnabled = value;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, value);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error saving notification settings: $e');
      }
      notifyListeners();
    }
  }
} 