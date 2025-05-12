import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';

class UserForm extends StatefulWidget {
  final String role;

  const UserForm({Key? key, required this.role}) : super(key: key);

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;
    
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('$userId.jpg');
      
      // Upload the image
      await ref.putFile(_selectedImage!);
      
      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (isSuccess) {
      AppSnackbar.showSuccess(
        context: context,
        message: message,
      );
    } else {
      AppSnackbar.showError(
        context: context,
        message: message,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create user in Firebase Auth
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          final userId = userCredential.user!.uid;
          
          // Upload image if selected
          String? photoUrl;
          if (_selectedImage != null) {
            photoUrl = await _uploadImage(userId);
          }
          
          // Create user model
          final newUser = UserModel(
            id: userId,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            role: widget.role,
            isActive: true,
            title: widget.role == 'mentor' ? _titleController.text.trim() : null,
            photoUrl: photoUrl,
            status: widget.role == 'teacher' || widget.role == 'mentor' ? 'pending_approval' : 'active',
            isApproved: widget.role == 'teacher' || widget.role == 'mentor' ? false : true,
          );

          // Add user to Firestore
          final userController = Provider.of<UserController>(context, listen: false);
          final result = await userController.addUser(newUser);

          if (result) {
            _showSnackBar('${widget.role.capitalize()} added successfully');
            Navigator.pop(context);
          } else {
            _showSnackBar('Failed to add user', isSuccess: false);
          }
        }
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', isSuccess: false);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.role.capitalize()}'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                        child: _selectedImage == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.role == 'mentor')
                Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (e.g. CS Professor)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Add ${widget.role.capitalize()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
} 