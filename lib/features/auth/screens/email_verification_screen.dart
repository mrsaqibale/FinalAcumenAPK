import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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
          print("Email verified! Moving to dashboard screen.");
        }

        setState(() {
          _isVerified = true;
          _isLoading = false;
        });

        if (mounted) {
          // Navigate to dashboard screen
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify your Email',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            height:
                screenSize.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/mail.png',
                  height: screenSize.height * 0.15,
                  width: screenSize.height * 0.15,
                ),
                const SizedBox(height: 40),
                Text(
                  'We\'ve sent a verification email to:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please check your email and click the verification link to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(color: AppTheme.primaryColor)
                else
                  Column(
                    children: [
                      PrimaryButton(
                        text: 'I\'ve Verified My Email',
                        width: 250,
                        onPressed: _checkEmailVerification,
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _resendVerificationEmail,
                        child: const Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
