import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailConfirmationScreen extends StatelessWidget {
  final String email;

  const EmailConfirmationScreen({
    super.key,
    this.email = 'Email@gmail.com',
  });

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
              email,
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
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Resend Email',
              width: 250,
              onPressed: () {
                // Resend email logic
              },
            ),
          ],
        ),
      ),
    );
  }
} 
