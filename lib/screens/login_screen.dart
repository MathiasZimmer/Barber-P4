import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key to access form state and validation
  final _formKey = GlobalKey<FormState>();
  // Store email and password values
  String? _email;
  String? _password;
  // Loading state to handle async operations
  bool _isLoading = false;

  Future<void> _login() async {
    // Validate form fields before proceeding
    if (!_formKey.currentState!.validate()) return;
    // Save form field values to state variables
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Basic email format validation
      if (!_email!.contains('@')) throw Exception('Ugyldig email format');
      // Password length validation
      if (_password!.length < 6) {
        throw Exception('Adgangskode skal være mindst 6 tegn');
      }

      // Attempt to login using UserService
      final success = await UserService().login(_email!, _password!);
      if (!success) throw Exception('Forkert email eller adgangskode');

      // Artificial delay to show loading state
      await Future.delayed(const Duration(seconds: 1));

      // Check if widget is still mounted after async operations
      if (!mounted) return;

      // Navigate to user profile on successful login
      Navigator.pushReplacementNamed(context, '/user_profile');
    } catch (e) {
      // Handle errors and show error message to user
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login fejlede: $e')));
    }

    // Reset loading state if widget is still mounted
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text('LOG IND', style: AppTheme.appBarTitleStyle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Container with gold border decoration for form fields
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: AppTheme.goldBorderContainer,
                child: Column(
                  children: [
                    // Email input field with validation
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      style: AppTheme.titleStyle,
                      onSaved: (value) => _email = value,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Indtast venligst din email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password input field with validation and obscured text
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adgangskode',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      style: AppTheme.titleStyle,
                      obscureText: true,
                      onSaved: (value) => _password = value,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Indtast venligst din adgangskode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Login button with loading state
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _isLoading ? 'Logger ind...' : 'LOGIN',
                          style: AppTheme.buttonTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
