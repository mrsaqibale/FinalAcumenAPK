import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:acumen/features/dashboard/utils/loading_dialog.dart';
import 'package:acumen/theme/app_colors.dart';
import '../repositories/profile_repository.dart';
import '../widgets/profile_image_widget.dart';
import '../widgets/profile_edit_field.dart';
import '../widgets/profile_skills_widget.dart';
import 'package:acumen/utils/app_snackbar.dart';
import '../models/skill_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _profileRepository = ProfileRepository();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  
  double _profileImageTop = 30;
  bool _isLoading = true;
  String? _errorMessage;
  String? _profileImageUrl;
  File? _selectedImageFile;
  List<SkillModel> userSkills = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadUserData();
  }

  void _handleScroll() {
    setState(() {
      _profileImageTop = 30 - (_scrollController.offset * 0.15).clamp(0, 20);
    });
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = await _profileRepository.loadUserData();
      final imageUrl = await _profileRepository.getProfileImageUrl();
      
      setState(() {
        _nameController.text = userData['name'];
        _bioController.text = userData['bio'];
        userSkills = List<SkillModel>.from(userData['skills']);
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
    });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      // For Android 13 and above
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      return false;
    } else if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> _handleCameraTap() async {
    try {
      // Request permissions first
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          AppSnackbar.showError(
            context: context,
            message: 'Permission to access photos was denied',
          );
        }
        return;
      }

      // Show a bottom sheet to choose between camera and gallery
      if (!mounted) return;
      
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error selecting image: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleAddSkill(String name, File? file, String? fileType) async {
    try {
      final newSkill = await _profileRepository.addSkill(
        name: name,
        file: file,
        fileType: fileType,
      );
      
      setState(() {
        userSkills.add(newSkill);
      });
      
      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Skill added successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error adding skill: ${e.toString()}',
        );
      }
    }
  }

  void _handleRemoveSkill(String skillId) async {
    try {
      await _profileRepository.removeSkill(skillId);
      
    setState(() {
        userSkills.removeWhere((skill) => skill.id == skillId);
    });
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error removing skill: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await LoadingDialog.showWhile(
        context,
        () async {
          // First upload the profile image if one was selected
          if (_selectedImageFile != null) {
            await _profileRepository.uploadProfileImage(_selectedImageFile!);
          }
          
          // Then save the profile data
          await _profileRepository.saveProfile(
            name: _nameController.text,
            bio: _bioController.text,
            skills: userSkills,
          );
        },
      );

      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Profile updated successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error updating profile: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
          : Stack(
        children: [
          Column(
            children: [
                    const SizedBox(height: 80),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                          color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                          child: Form(
                            key: _formKey,
                    child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                                  ProfileEditField(
                                    controller: _nameController,
                            hintText: 'Enter your name',
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Bio field
                          const Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                                  ProfileEditField(
                                    controller: _bioController,
                            hintText: 'Tell us about yourself',
                            maxLines: 3,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Skills section
                                  ProfileSkillsWidget(
                                    skills: userSkills,
                                    onRemoveSkill: _handleRemoveSkill,
                                    onAddSkill: _handleAddSkill,
                                    skillController: _skillsController,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Save button
                          Center(
                            child: Container(
                              width: 200,
                              height: 45,
                              decoration: BoxDecoration(
                                        color: AppColors.primary,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextButton(
                                onPressed: _saveProfile,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                      ),
                    ),
                  ),
                ],
              ),
                
                // Profile image
                ProfileImageWidget(
                  topPosition: _profileImageTop,
                  onCameraTap: _handleCameraTap,
                  imageUrl: _profileImageUrl,
                  imageFile: _selectedImageFile,
            showCameraIcon: true,
          ),
        ],
      ),
    );
  }
} 