import 'package:acumen/features/auth/screens/forgot_password_screen.dart';
import 'package:acumen/features/auth/screens/signup_screen.dart';
import 'package:acumen/features/auth/screens/mentor_login_screen.dart';
import 'package:acumen/features/auth/screens/mentor_signup_screen.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:acumen/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController rollNumberController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool isLoading;
  final ValueChanged<bool>? onLoginModeChanged;

  const LoginForm({
    super.key,
    required this.rollNumberController,
    required this.passwordController,
    required this.onLogin,
    this.isLoading = false,
    this.onLoginModeChanged,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isAdminLogin = false;
  
  void _trySubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (isValid) {
      widget.onLogin();
    }
  }

  void _toggleLoginMode(bool value) {
    setState(() {
      _isAdminLogin = value;
      // Clear the field when switching login modes
      widget.rollNumberController.clear();
    });
    
    // Notify parent about the change
    if (widget.onLoginModeChanged != null) {
      widget.onLoginModeChanged!(value);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                _isAdminLogin ? 'Admin Login' : 'Student Login',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Toggle switch between student and admin login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Student'),
                  Switch(
                    value: _isAdminLogin,
                    onChanged: _toggleLoginMode,
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Text('Admin'),
                ],
              ),
              
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.rollNumberController,
                hintText: _isAdminLogin ? 'Enter Email' : 'Enter Roll Number',
                prefixIcon: Icon(
                  _isAdminLogin ? Icons.email : Icons.tag,
                  color: Colors.grey
                ),
                validator: _isAdminLogin 
                  ? LoginValidation.validateEmail 
                  : LoginValidation.validateRollNumber,
              ),
              const SizedBox(height: 5),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forget Password?',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
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
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                ),
              ),
              const SizedBox(height: 10),
              if (!_isAdminLogin)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MentorLoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login as Mentor',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 10),
              if (!_isAdminLogin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: AppTheme.accentColor),
                      ),
                    ),
                  ],
                ),
              // const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text(
              //         "Are you a Admin?",
              //       style: TextStyle(color: Colors.grey),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const AdminDashboardScreen(),
              //           ),
              //         );
              //       },
              //       child: const Text(
              //           'Mentor Sign Up',
              //         style: TextStyle(color: AppTheme.accentColor),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
} 