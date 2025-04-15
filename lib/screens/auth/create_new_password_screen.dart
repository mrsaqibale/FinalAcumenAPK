import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
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
          'Create New Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/password.png',
                height: screenSize.height * 0.20,
                width: screenSize.height * 0.20,
              ),
              const SizedBox(height: 60),
              const Text(
                'Your new password must be different\nfrom previous one',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              _buildPasswordField(
                'New Password',
                passwordController,
                false,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                'Confirm Password',
                confirmPasswordController,
                false,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'Save',
                width: 250,
                onPressed: () {
                  if (passwordController.text == confirmPasswordController.text &&
                      passwordController.text.isNotEmpty) {
                    // Handle password change logic
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match or are empty'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hintText,
    TextEditingController controller,
    bool autoFocus,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const SizedBox(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
} 
