import 'package:acumen/features/auth/services/signup_service.dart';
import 'package:acumen/features/auth/widgets/signup_form.dart';
import 'package:acumen/features/auth/widgets/signup_header.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SignupService _signupService = SignupService();

  bool isFirstSemester = false;
  PlatformFile? selectedFile;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    rollNoController.dispose();
    passwordController.dispose();
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
    setState(() {
      isLoading = true;
    });

    try {
      await _signupService.signup(
        context: context,
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        rollNo: rollNoController.text,
        isFirstSemester: isFirstSemester,
        document: selectedFile,
      );
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
              child: SignupForm(
                emailController: emailController,
                nameController: nameController,
                rollNoController: rollNoController,
                passwordController: passwordController,
                isFirstSemester: isFirstSemester,
                onFirstSemesterChanged: (value) {
                  setState(() {
                    isFirstSemester = value!;
                  });
                },
                selectedFile: selectedFile,
                onPickFile: _pickDocumentFile,
                onViewFile: _viewFile,
                onSignUp: _signup,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}