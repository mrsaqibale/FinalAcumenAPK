import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';


class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final bool isLoading;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 220, // Smaller width for buttons
    this.height = 45, // Adjusted height to match screenshot
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 
