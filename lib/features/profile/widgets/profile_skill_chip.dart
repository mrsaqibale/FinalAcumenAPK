import 'package:flutter/material.dart';

class ProfileSkillChip extends StatelessWidget {
  final String skill;
  final VoidCallback? onRemove;
  final bool isRemovable;

  const ProfileSkillChip({
    super.key,
    required this.skill,
    this.onRemove,
    this.isRemovable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withAlpha(128)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            skill,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        if (isRemovable && onRemove != null)
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
} 