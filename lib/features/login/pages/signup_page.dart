import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/pages/dashboard_page.dart';
import 'package:office_management/core/services/supabase_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<ShadFormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  String? _errorMessage;
  bool _showErrorAlert = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true;
        _showErrorAlert = false;
        _errorMessage = null;
      });
      try {
        final response = await SupabaseService().signUp(
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
              _errorMessage = 'Signup failed. Please try again.';
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
          title: const Text('Sign Up'),
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
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'confirmPassword',
                  controller: _confirmPasswordController,
                  label: const Text('Confirm Password'),
                  placeholder: const Text('Confirm your password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
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
                            color: ShadTheme.of(context).colorScheme.primaryForeground,
                          ),
                        )
                      : const Icon(LucideIcons.mail),
                  onPressed: _isLoading ? null : _handleSignup,
                  child: Text(_isLoading ? 'Please wait' : 'Sign Up'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

