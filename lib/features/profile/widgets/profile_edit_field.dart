import 'package:flutter/material.dart';

class ProfileEditField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;

  const ProfileEditField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          suffixIcon: readOnly ? null : const Icon(
            Icons.edit,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }
} 