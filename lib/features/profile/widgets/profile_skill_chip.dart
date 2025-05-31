import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSkillChip extends StatelessWidget {
  final String skill;
  final VoidCallback? onRemove;
  final bool isRemovable;
  final bool isVerified;

  const ProfileSkillChip({
    super.key,
    required this.skill,
    this.onRemove,
    this.isRemovable = false,
    this.isVerified = false,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVerified)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    FontAwesomeIcons.solidCircleCheck,
                    color: Colors.blue,
                    size: 14,
                  ),
                ),
              Flexible(
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
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