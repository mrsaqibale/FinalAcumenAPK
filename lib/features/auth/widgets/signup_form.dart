import 'package:acumen/features/auth/screens/mentor_signup_screen.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController rollNoController;
  final TextEditingController passwordController;
  final bool isFirstSemester;
  final Function(bool?) onFirstSemesterChanged;
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  final VoidCallback onViewFile;
  final VoidCallback onSignUp;
  final bool isLoading;

  const SignupForm({
    super.key,
    required this.emailController,
    required this.nameController,
    required this.rollNoController,
    required this.passwordController,
    required this.isFirstSemester,
    required this.onFirstSemesterChanged,
    required this.selectedFile,
    required this.onPickFile,
    required this.onViewFile,
    required this.onSignUp,
    this.isLoading = false,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (isValid) {
      if (widget.selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a document'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      widget.onSignUp();
    }
  }

  // Get icon for file type
  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get color for file icon
  Color _getFileIconColor(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                children: [
                  Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Back to login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
                controller: widget.nameController,
              hintText: 'Enter Full Name',
              prefixIcon: const Icon(Icons.person, color: Colors.grey),
                validator: LoginValidation.validateName,
            ),
            const SizedBox(height: 10),
            CustomTextField(
                controller: widget.rollNoController,
              hintText: 'Enter Roll number',
              prefixIcon: const Icon(Icons.tag, color: Colors.grey),
              keyboardType: TextInputType.number,
                validator: LoginValidation.validateRollNumber,
            ),
            const SizedBox(height: 10),
            CustomTextField(
                controller: widget.emailController,
              hintText: 'Enter your Email Address',
              prefixIcon: const Icon(Icons.email, color: Colors.grey),
              keyboardType: TextInputType.emailAddress,
                validator: LoginValidation.validateEmail,
            ),
            const SizedBox(height: 10),
            CustomTextField(
                controller: widget.passwordController,
              hintText: 'Password',
              obscureText: true,
                validator: LoginValidation.validatePassword,
              prefixIcon: const SizedBox(
                width: 12,
                height: 12,
                child: Center(
                  child: ImageIcon(
                    AssetImage('assets/images/icons/lock.png'),
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                    value: widget.isFirstSemester,
                    onChanged: widget.onFirstSemesterChanged,
                ),
                const Text('Are you in first semester?'),
              ],
            ),
            const SizedBox(height: 20),
              if (widget.selectedFile != null) ...[
              ListTile(
                leading: Icon(
                    _getFileIcon(widget.selectedFile!.name),
                    color: _getFileIconColor(widget.selectedFile!.name),
                ),
                  title: Text(widget.selectedFile!.name),
                subtitle: Text(
                    '${(widget.selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility),
                    onPressed: widget.onViewFile,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Center(
              child: PrimaryButton(
                  text: widget.isFirstSemester
                    ? 'Upload Admission Slip (PDF/Image)'
                    : 'Upload Transcript (PDF/Image)',
                width: 250,
                  onPressed: widget.onPickFile,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                    onPressed: widget.isLoading ? null : _trySubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.7),
                  ),
                    child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Are you a mentor?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MentorSignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Mentor Sign Up',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
} 