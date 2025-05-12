import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/auth/screens/mentor_signup_screen.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/utils/app_snackbar.dart';

class MentorLoginScreen extends StatefulWidget {
  const MentorLoginScreen({super.key});

  @override
  State<MentorLoginScreen> createState() => _MentorLoginScreenState();
}

class _MentorLoginScreenState extends State<MentorLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authController.mentorSignIn(
        email: _emailController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        password: _passwordController.text,
        context: context,
      );

      if (user != null && mounted) {
        // Navigate to mentor dashboard
        Navigator.pushReplacementNamed(context, '/mentor-dashboard');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during mentor login: $e");
      }
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    
                      const Text(
                        'Mentor Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Access your mentor account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // Login Form
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
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _emailController,
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
                              controller: _employeeIdController,
                              decoration: const InputDecoration(
                                labelText: 'Employee ID',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge, color: Colors.grey),
                              ),
                              validator: LoginValidation.validateEmployeeId,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                              ),
                              obscureText: true,
                              validator: LoginValidation.validatePassword,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forgot-password');
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppTheme.accentColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.7),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have a mentor account?",
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
                                    'Sign Up',
                                    style: TextStyle(color: AppTheme.accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 