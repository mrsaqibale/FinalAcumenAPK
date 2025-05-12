import 'package:acumen/features/auth/services/signup_service.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/features/auth/widgets/signup_header.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/utils/app_snackbar.dart';

class MentorSignupScreen extends StatefulWidget {
  const MentorSignupScreen({super.key});

  @override
  State<MentorSignupScreen> createState() => _MentorSignupScreenState();
}

class _MentorSignupScreenState extends State<MentorSignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final SignupService _signupService = SignupService();
  final _formKey = GlobalKey<FormState>();

  PlatformFile? selectedFile;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    employeeIdController.dispose();
    passwordController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  // Pick a document file
  Future<void> _pickDocumentFile() async {
    final file = await _signupService.pickDocumentFile(context);
    if (file != null) {
      setState(() {
        selectedFile = file;
      });
    }
  }

  // View selected file
  void _viewFile() {
    if (selectedFile == null) return;
    
    final fileExt = selectedFile!.name.toLowerCase().split('.').last;
    if (fileExt == 'pdf') {
      _showErrorMessage("PDF viewer will be implemented here");
    } else if (['png', 'jpg', 'jpeg'].contains(fileExt)) {
      _showErrorMessage("Image viewer will be implemented here");
    }
  }

  // Signup function
  Future<void> _signup() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (!isValid) {
      return;
    }
    
    if (selectedFile == null) {
      _showErrorMessage("Please upload your credentials document");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await _signupService.signupMentor(
        context: context,
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        employeeId: employeeIdController.text,
        department: departmentController.text,
        document: selectedFile,
      );
      
      if (!success && mounted) {
        _showErrorMessage("Signup failed. Please try again.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in mentor signup: $e");
      }
      _showErrorMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    AppSnackbar.showError(
      context: context,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const SignupHeader(),
            Expanded(
              child: Container(
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
                          'Mentor Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                        ),
                          validator: LoginValidation.validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: employeeIdController,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge, color: Colors.grey),
                        ),
                          validator: LoginValidation.validateEmployeeId,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business, color: Colors.grey),
                        ),
                          validator: LoginValidation.validateDepartment,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                        ),
                        keyboardType: TextInputType.emailAddress,
                          validator: LoginValidation.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        ),
                        obscureText: true,
                          validator: LoginValidation.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      if (selectedFile != null) ...[
                        ListTile(
                          leading: Icon(
                            selectedFile!.name.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: selectedFile!.name.toLowerCase().endsWith('.pdf')
                                ? Colors.red
                                : Colors.blue,
                          ),
                          title: Text(selectedFile!.name),
                          subtitle: Text(
                            '${(selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: _viewFile,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _pickDocumentFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Credentials (PDF/Image)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                            ),
                            disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.7),
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
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 