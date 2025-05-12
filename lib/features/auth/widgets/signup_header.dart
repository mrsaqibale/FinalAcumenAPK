import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
} 