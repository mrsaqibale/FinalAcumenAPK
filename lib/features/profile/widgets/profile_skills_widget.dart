import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:acumen/features/profile/models/skill_model.dart';
import 'package:acumen/utils/app_snackbar.dart';

class ProfileSkillsWidget extends StatelessWidget {
  final List<SkillModel> skills;
  final Function(String) onRemoveSkill;
  final Function(String, File?, String?) onAddSkill;
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

  Widget _buildSkillChip(SkillModel skill, BuildContext context) {
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
          if (skill.isVerified)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: Colors.blue,
                size: 16,
              ),
            ),
          Text(
            skill.name,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          if (skill.fileUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                skill.fileType == 'pdf' ? FontAwesomeIcons.filePdf : FontAwesomeIcons.fileImage,
                color: Colors.grey[700],
                size: 14,
              ),
            ),
          GestureDetector(
            onTap: () => onRemoveSkill(skill.id),
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
    File? selectedFile;
    String? fileType;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
        title: const Text('Add a new skill'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
          controller: skillController,
          decoration: const InputDecoration(
                    labelText: 'Skill name',
            hintText: 'Enter skill name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload certification or proof (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          );
                          
                          if (result != null) {
                            setState(() {
                              selectedFile = File(result.files.single.path!);
                              fileType = result.files.single.extension == 'pdf' ? 'pdf' : 'image';
                            });
                          }
                        },
                        icon: Icon(selectedFile == null ? Icons.upload_file : Icons.check_circle),
                        label: Text(selectedFile == null ? 'Choose File' : 'File Selected'),
                      ),
                    ),
                    if (selectedFile != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                            fileType = null;
                          });
                        },
                      ),
                  ],
                ),
                if (selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'File type: ${fileType == 'pdf' ? 'PDF Document' : 'Image'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSkill = skillController.text.trim();
                  if (newSkill.isNotEmpty && !skills.any((s) => s.name == newSkill)) {
                    onAddSkill(newSkill, selectedFile, fileType);
              Navigator.pop(context);
                  } else if (skills.any((s) => s.name == newSkill)) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'This skill is already in your list',
                    );
                  }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Add'),
          ),
        ],
          );
        },
      ),
    );
  }
} 