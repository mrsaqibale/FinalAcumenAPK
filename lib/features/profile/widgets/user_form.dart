import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';

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
  final _passwordController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _titleController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _isFirstSemester = false;
  File? _selectedImage;
  PlatformFile? _selectedDocument;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNoController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _titleController.dispose();
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

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedDocument = result.files.first;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking document: $e', isSuccess: false);
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;
    
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('$userId.jpg');
      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading image: $e', isSuccess: false);
      return null;
    }
  }

  Future<String?> _uploadDocument(String userId) async {
    if (_selectedDocument == null) return null;
    
    try {
      final ref = FirebaseStorage.instance.ref()
          .child('documents')
          .child(widget.role)
          .child('$userId.${_selectedDocument!.extension}');
      
      // Handle both file path and bytes
      if (_selectedDocument!.path != null) {
        // If we have a file path, upload using the file
        await ref.putFile(File(_selectedDocument!.path!));
      } else if (_selectedDocument!.bytes != null) {
        // If we have bytes, upload using the bytes
        await ref.putData(_selectedDocument!.bytes!);
      } else {
        throw Exception('Document has neither path nor bytes');
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading document: $e', isSuccess: false);
      return null;
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (isSuccess) {
      AppSnackbar.showSuccess(context: context, message: message);
    } else {
      AppSnackbar.showError(context: context, message: message);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate document for students and mentors
    if ((widget.role == 'student' || widget.role == 'mentor') && _selectedDocument == null) {
      _showSnackBar('Please upload required document', isSuccess: false);
      return;
    }

    // Additional validation for document
    if (_selectedDocument != null && _selectedDocument!.path == null && _selectedDocument!.bytes == null) {
      _showSnackBar('Invalid document selected', isSuccess: false);
      return;
    }

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
        
        // Upload image and document if selected
        String? photoUrl;
        String? documentUrl;
        
        try {
          if (_selectedImage != null) {
            photoUrl = await _uploadImage(userId);
          }
          
          if (_selectedDocument != null) {
            documentUrl = await _uploadDocument(userId);
            if (documentUrl == null) {
              throw Exception('Failed to upload document');
            }
          }

          // Create user model based on role
          final newUser = UserModel(
            id: userId,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            role: widget.role,
            isActive: true,
            title: widget.role == 'mentor' ? _titleController.text.trim() : null,
            photoUrl: photoUrl,
            status: widget.role == 'mentor' ? 'pending_approval' : 'active',
            isApproved: widget.role == 'mentor' ? false : true,
            employeeId: widget.role == 'mentor' ? _employeeIdController.text.trim() : null,
            department: widget.role == 'mentor' ? _departmentController.text.trim() : null,
            rollNo: widget.role == 'student' ? int.tryParse(_rollNoController.text.trim()) : null,
            isFirstSemester: widget.role == 'student' ? _isFirstSemester : null,
            document: documentUrl,
          );

          // Add user to Firestore
          final userController = Provider.of<UserController>(context, listen: false);
          final result = await userController.addUser(newUser);

          if (result) {
            if (mounted) {
              _showSnackBar('${widget.role.capitalize()} added successfully');
              
              // Show success dialog before navigating
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: Text(
                    widget.role == 'mentor' 
                        ? 'Mentor has been added and is pending approval. You can approve them from the Mentors tab.'
                        : '${widget.role.capitalize()} has been added successfully.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to dashboard
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            throw Exception('Failed to add user to database');
          }
        } catch (e) {
          // If anything fails after user creation, delete the user
          await userCredential.user!.delete();
          throw e;
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isSuccess: false);
      }
    } finally {
      if (mounted) {
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
        title: Text(
          'Add ${widget.role.capitalize()}',
          style: const TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.textLight),
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
                            ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
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

              // Common fields for all roles
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: LoginValidation.validateName,
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
                validator: LoginValidation.validateEmail,
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
                validator: LoginValidation.validatePassword,
              ),
              const SizedBox(height: 16),

              // Role-specific fields
              if (widget.role == 'student') ...[
                TextFormField(
                  controller: _rollNoController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  keyboardType: TextInputType.number,
                  validator: LoginValidation.validateRollNumber,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isFirstSemester,
                      onChanged: (value) {
                        setState(() {
                          _isFirstSemester = value ?? false;
                        });
                      },
                    ),
                    const Text('Is First Semester Student?'),
                  ],
                ),
                const SizedBox(height: 16),
                // Document upload for students
                ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedDocument == null 
                    ? 'Upload Student Document' 
                    : 'Document: ${_selectedDocument!.name}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],

              if (widget.role == 'mentor') ...[
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: LoginValidation.validateEmployeeId,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: LoginValidation.validateDepartment,
                ),
                const SizedBox(height: 16),
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
                // Document upload for mentors
                ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedDocument == null 
                    ? 'Upload Credentials Document' 
                    : 'Document: ${_selectedDocument!.name}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],

              const SizedBox(height: 24),
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