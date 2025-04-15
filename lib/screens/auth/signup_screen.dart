import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'email_confirmation_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar to white text
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    
    final TextEditingController emailController = TextEditingController();
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildSignupForm(context, emailController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: const Column(
        children: [
          Text(
            "Let's",
            style: AppTheme.headingStyle,
          ),
          SizedBox(height: 8),
          Text(
            'Get Started!',
            style: AppTheme.headingStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context, TextEditingController emailController) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                children: [
                  Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Back to login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const CustomTextField(
              hintText: 'Enter Roll number',
              prefixIcon: Icon(Icons.tag, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: emailController,
              hintText: 'Enter your Email Address',
              prefixIcon: const Icon(Icons.email, color: Colors.grey),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            const CustomTextField(
              hintText: 'Password',
              obscureText: true,
              prefixIcon: SizedBox(
                width: 12,
                height: 12,
                child: Center(
                  child: ImageIcon(
                    AssetImage('assets/images/icons/lock.png'),
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const CustomTextField(
              hintText: 'Confirm Password',
              obscureText: true,
              prefixIcon: SizedBox(
                width: 12,
                height: 12,
                child: Center(
                  child: ImageIcon(
                    AssetImage('assets/images/icons/lock.png'),
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: PrimaryButton(
                text: 'Upload Transcript (PDF)',
                width: 250,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: PrimaryButton(
                text: 'Sign up',
                width: 200,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailConfirmationScreen(
                        email: emailController.text.isEmpty 
                            ? 'Email@gmail.com' 
                            : emailController.text,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
