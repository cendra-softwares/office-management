import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/pages/dashboard_page.dart';
import 'package:office_management/core/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<ShadFormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _errorMessage;
  bool _showErrorAlert = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true;
        _showErrorAlert = false;
        _errorMessage = null;
      });
      try {
        final response = await SupabaseService().signIn(
          _emailController.text,
          _passwordController.text,
        );
        if (response.user != null) {
          // Navigate to dashboard
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        } else {
          // Show error message
          if (mounted) {
            setState(() {
              _errorMessage = 'Login failed. Please check your credentials.';
              _showErrorAlert = true;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error: $e';
            _showErrorAlert = true;
          });
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ShadCard(
          width: 350,
          title: const Text('Login'),
          child: ShadForm(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showErrorAlert && _errorMessage != null)
                  ShadAlert.destructive(
                    iconData: LucideIcons.circleAlert,
                    title: const Text('Error'),
                    description: Text(_errorMessage!),
                  ),
                if (_showErrorAlert && _errorMessage != null)
                  const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'email',
                  controller: _emailController,
                  label: const Text('Email'),
                  placeholder: const Text('Enter your email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'password',
                  controller: _passwordController,
                  label: const Text('Password'),
                  placeholder: const Text('Enter your password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ShadButton(
                  leading: _isLoading
                      ? SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.primaryForeground,
                          ),
                        )
                      : const Icon(LucideIcons.mail),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: Text(_isLoading ? 'Please wait' : 'Login'),
                ),
                const SizedBox(height: 16),

                // TODO: Add "Forgot Password" functionality
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
