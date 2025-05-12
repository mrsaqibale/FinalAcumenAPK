import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
} 