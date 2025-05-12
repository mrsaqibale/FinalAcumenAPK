import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
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
          'Forgot Password',
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
                  'assets/images/password.png',
                  height: screenSize.height * 0.15,
                  width: screenSize.height * 0.15,
                ),
                const SizedBox(height: 80),
                const Text(
                  'Please Enter your email Address\nto receive a verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                const CustomTextField(
                  hintText: 'Enter Roll Number',
                  prefixIcon: Icon(Icons.tag, color: Colors.grey),
                ),
                const SizedBox(height: 15),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailVerificationScreen(
                            email: emailController.text.isEmpty 
                                ? 'Email@gmail.com' 
                                : emailController.text,
                          ),
                        ),
                      );
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
