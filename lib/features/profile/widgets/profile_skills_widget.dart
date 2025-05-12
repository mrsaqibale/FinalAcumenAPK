import 'package:flutter/material.dart';
import 'package:acumen/theme/app_colors.dart';

class ProfileSkillsWidget extends StatelessWidget {
  final List<String> skills;
  final Function(String) onRemoveSkill;
  final VoidCallback onAddSkill;
  final TextEditingController skillController;

  const ProfileSkillsWidget({
    super.key,
    required this.skills,
    required this.onRemoveSkill,
    required this.onAddSkill,
    required this.skillController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...skills.map((skill) => _buildSkillChip(skill, context)).toList(),
            _buildAddSkillButton(context),
          ],
        ),
        if (skills.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No skills added yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillChip(String skill, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemoveSkill(skill),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillButton(BuildContext context) {
    return InkWell(
      onTap: () => _showAddSkillDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(30),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 16, color: AppColors.primary),
            SizedBox(width: 4),
            Text(
              'Add Skill',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    skillController.text = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a new skill'),
        content: TextField(
          controller: skillController,
          decoration: const InputDecoration(
            hintText: 'Enter skill name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSkill = skillController.text.trim();
              if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
                onAddSkill();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 