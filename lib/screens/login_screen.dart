import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (!_email!.contains('@')) throw Exception('Ugyldig email format');
      if (_password!.length < 6) {
        throw Exception('Adgangskode skal være mindst 6 tegn');
      }

      final success = await UserService().login(_email!, _password!);
      if (!success) throw Exception('Forkert email eller adgangskode');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return; // Check after async gap

      Navigator.pushReplacementNamed(
        context,
        '/user_profile',
      ); // Use context directly
    } catch (e) {
      if (!mounted) return; // Check again before using context

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login fejlede: $e')));
    }

    if (mounted) {
      setState(() => _isLoading = false); // Safe to call setState
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
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: AppTheme.goldBorderContainer,
                child: Column(
                  children: [
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
