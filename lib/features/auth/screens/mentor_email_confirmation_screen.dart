import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorEmailConfirmationScreen extends StatefulWidget {
  final String email;

  const MentorEmailConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  State<MentorEmailConfirmationScreen> createState() => _MentorEmailConfirmationScreenState();
}

class _MentorEmailConfirmationScreenState extends State<MentorEmailConfirmationScreen> {
  final AuthController _authController = AuthController();
  bool _isLoading = false;
  bool _isVerified = false;
  
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  // Check email verification status periodically
  Future<void> _checkEmailVerification() async {
    if (_isVerified) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final isVerified = await _authController.isEmailVerified();
      
      if (isVerified) {
        if (kDebugMode) {
          print("Email verified! Moving to approval screen.");
        }
        
        setState(() {
          _isVerified = true;
          _isLoading = false;
        });
        
        _navigateToApprovalScreen();
      } else {
        if (kDebugMode) {
          print("Email not verified yet. Will check again in 3 seconds.");
        }
        
        setState(() {
          _isLoading = false;
        });
        
        // Check again after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _checkEmailVerification();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking email verification: $e");
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToApprovalScreen() {
    if (!mounted) return;
    AppRoutes.navigateToMentorApproval(context, widget.email);
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authController.resendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Verify Your Email',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.email,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Confirm your Email Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Before we can activate your mentor account, please verify your email address.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Please check your email and click the verification link to continue.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'After verifying your email, you\'ll need to wait for an administrator to approve your mentor account.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.primaryColor)
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _checkEmailVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'I\'ve Verified My Email',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _resendVerificationEmail,
                      child: const Text(
                        'Resend Verification Email',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 