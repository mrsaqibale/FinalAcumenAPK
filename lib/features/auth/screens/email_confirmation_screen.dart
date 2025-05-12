import 'dart:async';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/utils/app_snackbar.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final AuthController _authController = AuthController();
  late Timer _timer;
  bool _isVerifying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start checking for email verification
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Check if email is verified
  Future<void> _checkEmailVerified() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isVerified = await _authController.isEmailVerified();
      
      if (isVerified) {
        _timer.cancel();
        
        // Navigate to dashboard
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error checking verification: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      await _authController.resendEmailVerification();
      
      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Verification email sent. Please check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      }
    }

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/email.png',
              height: 300,
              width: 300,
            ),
            const Text(
              'Confirm your email address',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'we sent a confirmation email to:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check your email and click on the\nconfirmation link to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 20),
            _isVerifying
                ? const CircularProgressIndicator()
                : PrimaryButton(
              text: 'Resend Email',
              width: 250,
                    onPressed: _resendVerificationEmail,
            ),
          ],
        ),
      ),
    );
  }
} 
