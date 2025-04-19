import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;

import 'email_confirmation_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rollNoController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool isFirstSemester = false;
    PlatformFile? selectedFile;
    String? fileUrl;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return _buildSignupForm(
                    context,
                    emailController,
                    nameController,
                    rollNoController,
                    passwordController,
                    isFirstSemester,
                        (value) => setState(() => isFirstSemester = value!),
                    selectedFile,
                    fileUrl,
                        () async {
                      // File picker
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (result != null) {
                        final file = result.files.first;
                        if (file.size > 2 * 1024 * 1024) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File size must be less than 2MB'),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          selectedFile = file;
                        });
                      }
                    },
                        () async {
                      // View PDF
                      if (selectedFile == null) return;
                      // Implement PDF viewer logic here
                      // You might want to use a package like 'flutter_pdf_viewer'
                    },
                        () async {
                      // Sign up
                      if (nameController.text.isEmpty ||
                          rollNoController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All fields are required'),
                          ),
                        );
                        return;
                      }

                      if (!emailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid email'),
                          ),
                        );
                        return;
                      }

                      if (int.tryParse(rollNoController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Roll number must be a number'),
                          ),
                        );
                        return;
                      }

                      if (selectedFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload the required document'),
                          ),
                        );
                        return;
                      }

                      try {
                        // Upload file to Firebase Storage
                        final storageRef = FirebaseStorage.instance.ref()
                            .child('user_documents')
                            .child('${DateTime.now().millisecondsSinceEpoch}.pdf');

                        await storageRef.putData(selectedFile!.bytes!);
                        fileUrl = await storageRef.getDownloadURL();

                        // Create user in Firebase Auth
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        // Save user data to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user?.uid)
                            .set({
                          'name': nameController.text,
                          'rollNo': int.parse(rollNoController.text),
                          'email': emailController.text,
                          'semester': isFirstSemester ? 1 : 2,
                          'documentUrl': fileUrl,
                          'documentType': isFirstSemester ? 'admission_slip' : 'transcript',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Navigate to confirmation screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailConfirmationScreen(
                              email: emailController.text,
                            ),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message ?? 'Signup failed'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: const Column(
        children: [
          Text(
            "Let's",
            style: AppTheme.headingStyle,
          ),
          SizedBox(height: 8),
          Text(
            'Get Started!',
            style: AppTheme.headingStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController nameController,
      TextEditingController rollNoController,
      TextEditingController passwordController,
      bool isFirstSemester,
      Function(bool?) onFirstSemesterChanged,
      PlatformFile? selectedFile,
      String? fileUrl,
      VoidCallback onPickFile,
      VoidCallback onViewFile,
      VoidCallback onSignUp,
      ) {
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
              controller: nameController,
              hintText: 'Enter Full Name',
              prefixIcon: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: rollNoController,
              hintText: 'Enter Roll number',
              prefixIcon: const Icon(Icons.tag, color: Colors.grey),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: emailController,
              hintText: 'Enter your Email Address',
              prefixIcon: const Icon(Icons.email, color: Colors.grey),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
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
                  value: isFirstSemester,
                  onChanged: onFirstSemesterChanged,
                ),
                const Text('Are you in first semester?'),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedFile != null) ...[
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(selectedFile!.name),
                subtitle: Text(
                  '${(selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: onViewFile,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Center(
              child: PrimaryButton(
                text: isFirstSemester
                    ? 'Upload Admission Slip (PDF)'
                    : 'Upload Transcript (PDF)',
                width: 250,
                onPressed: onPickFile,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: PrimaryButton(
                text: 'Sign up',
                width: 200,
                onPressed: onSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}