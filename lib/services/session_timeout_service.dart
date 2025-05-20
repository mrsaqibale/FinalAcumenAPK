import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionTimeoutService {
  static const String _timeoutKey = 'session_timeout_enabled';
  static const int _timeoutMinutes = 30;
  
  static Timer? _timer;
  static DateTime _lastActivity = DateTime.now();
  
  // Initialize and start monitoring user activity
  static void init(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_timeoutKey) ?? false;
    
    if (isEnabled) {
      startMonitoring(context);
    }
  }
  
  // Start monitoring user activity
  static void startMonitoring(BuildContext context) {
    // Cancel existing timer if any
    _timer?.cancel();
    
    // Reset last activity to now
    _lastActivity = DateTime.now();
    
    // Start a new timer that checks every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_timeoutKey) ?? false;
      
      // Check if timeout is still enabled
      if (!isEnabled) {
        timer.cancel();
        return;
      }
      
      // Check if it's been inactive for the timeout period
      final now = DateTime.now();
      final difference = now.difference(_lastActivity).inMinutes;
      
      if (difference >= _timeoutMinutes) {
        // Time to log out
        timer.cancel();
        _logOut(context);
      }
    });
  }
  
  // Call this method whenever there's user activity
  static void updateUserActivity() {
    _lastActivity = DateTime.now();
  }
  
  // Log out the user
  static void _logOut(BuildContext context) async {
    // Clear auth data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    // Show a dialog and navigate to login
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Session Expired"),
            content: const Text("Your session has expired due to inactivity."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Navigate to login and clear stack
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          );
        },
      );
    }
  }
  
  // Clean up when done
  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }
} 