import 'package:allo_doc/screens/doctor/home_doctor.dart';
import 'package:allo_doc/screens/patient/home_patient.dart';
import 'package:allo_doc/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMsg = '';
  String _selectedRole = 'patient';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      String? role = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole,
      );
      if (role == null) {
        setState(() {
          _errorMsg = 'Erreur lors de l\'inscription';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (role == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePatient()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeDoctor()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
              const SizedBox(height: 10),
              
              // Medical Branding Logo Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Titles
              Text(
                'Rejoignez AlloDoc',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Créez votre compte en quelques instants',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              // Name form row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Prénom',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Nom',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email & Password
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Adresse email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Role selection header label
              const Text(
                'Vous êtes :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              // Custom Toggle segmented capsule
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildRoleToggle('Patient', 'patient', Icons.person_outline),
                    _buildRoleToggle('Médecin', 'doctor', Icons.medical_services_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error box
              if (_errorMsg.isNotEmpty) ...[
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
                const SizedBox(height: 24),
              ],

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('S\'inscrire'),
              ),
              const SizedBox(height: 24),

              // Back to Login Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(text: "Déjà un compte ? "),
                      TextSpan(
                        text: "Se connecter",
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

  Widget _buildRoleToggle(String label, String roleValue, IconData icon) {
    final isSelected = _selectedRole == roleValue;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = roleValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
