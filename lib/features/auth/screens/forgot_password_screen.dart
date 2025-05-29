import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'email_verification_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
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
          'Reset Password',
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
                  'assets/images/password.png',
                  height: screenSize.height * 0.15,
                  width: screenSize.height * 0.15,
                ),
                const SizedBox(height: 80),
                const Text(
                  'Enter your email address to receive a verification code for password reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Enter your Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  text: 'Send Code',
                  width: 200,
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      AppSnackbar.showError(
                        context: context,
                        message: 'Please enter your email address.',
                      );
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: email,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  PasswordResetEmailSentScreen(email: email),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        AppSnackbar.showError(
                          context: context,
                          message: 'No user found with this email address.',
                        );
                      } else if (e.code == 'invalid-email') {
                        AppSnackbar.showError(
                          context: context,
                          message: 'The email address is not valid.',
                        );
                      } else {
                        AppSnackbar.showError(
                          context: context,
                          message: e.message ?? 'An error occurred.',
                        );
                      }
                    } catch (e) {
                      AppSnackbar.showError(
                        context: context,
                        message: e.toString(),
                      );
                    }
                  },
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

class PasswordResetEmailSentScreen extends StatelessWidget {
  final String email;

  const PasswordResetEmailSentScreen({super.key, required this.email});

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
          'Check Your Email',
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
                  'We\'ve sent a password reset link to:\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please check your email and click the link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Back to Login',
                  width: 250,
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
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
