import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/registration_provider.dart';
import '../routes/app_routes.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    setState(() => _loading = true);

    final message = await context.read<AuthProvider>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _loading = false);

    if (message != null) {
      Helpers.showSnack(context, message);
      return;
    }

    await context.read<EventProvider>().initialize();
    await context.read<RegistrationProvider>().initialize();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  String? _emailValidator(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    if (!email.endsWith('@charusat.ac.in')) {
      return 'Use a @charusat.ac.in email address.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FB), Color(0xFFEAF0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.event_available, size: 64, color: Color(0xFF1463FF)),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login with your CHARUSAT email to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            validator: _emailValidator,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'name@charusat.ac.in',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            validator: _passwordValidator,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: _loading ? 'Signing in...' : 'Login',
                            onPressed: _loading ? () {} : _submit,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Admin: rajan@charusat.ac.in / 12345678\nUser: any @charusat.ac.in email with a valid 8+ character password',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
