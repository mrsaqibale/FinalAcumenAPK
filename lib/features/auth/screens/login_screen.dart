import 'package:acumen/features/auth/utils/login_functions.dart';
import 'package:acumen/features/auth/widgets/login_form.dart';
import 'package:acumen/features/auth/widgets/login_header.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginFunctions _loginFunctions = LoginFunctions();
  bool isLoading = false;
  bool isAdminLogin = false;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _setAdminLoginMode(bool value) {
    setState(() {
      isAdminLogin = value;
    });
  }

  Future<void> _login() async {
    await _loginFunctions.login(
      identifier: identifierController.text,
      password: passwordController.text,
      context: context,
      isAdminLogin: isAdminLogin,
      setLoading: (value) {
        if (mounted) {
          setState(() {
            isLoading = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to white text
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const LoginHeader(),
              Expanded(
                child: LoginForm(
                  rollNumberController: identifierController,
                  passwordController: passwordController,
                  onLogin: _login,
                  isLoading: isLoading,
                  onLoginModeChanged: _setAdminLoginMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
