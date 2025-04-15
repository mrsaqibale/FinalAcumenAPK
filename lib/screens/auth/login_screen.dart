import 'package:acumen/screens/dashboard/dashboard_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
    
    final TextEditingController rollNumberController = TextEditingController();
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildLoginForm(context, rollNumberController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Column(
        children: const [
          Text(
            'Hello!',
            style: AppTheme.headingStyle,
          ),
          SizedBox(height: 8),
          Text(
            'Welcome to Acumen',
            style: AppTheme.headingStyle,
          ),
          SizedBox(height: 8),
          Text(
            'Connectify',
            style: AppTheme.headingStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, TextEditingController rollNumberController) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: rollNumberController,
              hintText: 'Enter Roll Number',
              prefixIcon: const Icon(Icons.tag, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: 'Password',
              obscureText: true,
              prefixIcon: SizedBox(
                width: 12,
                height: 12,
                child: Center(
                  child: ImageIcon(
                    AssetImage('assets/images/icons/lock.png'),
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forget Password?',
                  style: TextStyle(color: AppTheme.accentColor),
                ),
              ),
            ),
       
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Login',
              width: 250,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      username: rollNumberController.text.isNotEmpty 
                          ? rollNumberController.text 
                          : 'User name',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",style: TextStyle(color: Colors.grey),),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
