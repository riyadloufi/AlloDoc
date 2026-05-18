import 'package:allo_doc/screens/doctor/home_doctor.dart';
import 'package:allo_doc/screens/patient/home_patient.dart';
import 'package:allo_doc/screens/register_screen.dart';
import 'package:allo_doc/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMsg = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    String? role = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (role == null) {
      setState(() => _errorMsg = 'Email ou mot de passe incorrect');
    } else {
      if (role == 'patient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePatient()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDoctor()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Premium Medical Branding Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Typography Titles
              Text(
                'AlloDoc',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre santé connectée, en un clic',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 48),

              // Form Fields
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Adresse email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: const InputDecoration(
                  hintText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              
              // Error indicator
              if (_errorMsg.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEE2E2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMsg,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),

              // Action Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 32),

              // Navigation to Sign Up
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(text: "Pas encore de compte ? "),
                      TextSpan(
                        text: "S'inscrire",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
