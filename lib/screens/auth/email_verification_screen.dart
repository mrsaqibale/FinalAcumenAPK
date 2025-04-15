import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/auth/otp_input.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'create_new_password_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key, 
    this.email = 'Email@gmail.com'
  });

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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            height: screenSize.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/mail.png',
                  height: screenSize.height * 0.15,
                  width: screenSize.height * 0.15,
                ),
                const SizedBox(height: 80),
                Text(
                  'Please Enter the 4 digit code sent to\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                OTPInput(
                  onCompleted: (String value) {
                    // After OTP verification, navigate to Create New Password screen
                    if (value.length == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNewPasswordScreen(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Resend code
                  },
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: PrimaryButton(
                    text: 'Verify',
                    width: 250,
                    onPressed: () {
                      // Navigate to Create New Password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNewPasswordScreen(),
                        ),
                      );
                    },
                  ),
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
