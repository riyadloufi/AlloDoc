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
        setState(() => _errorMsg = 'Erreur lors de l\'inscription');
      } else {
        // Redirection selon le rôle
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
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Créer un compte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Vous êtes :'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Patient'),
                      value: 'patient',
                      groupValue: _selectedRole,
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Médecin'),
                      value: 'doctor',
                      groupValue: _selectedRole,
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_errorMsg.isNotEmpty)
                Text(_errorMsg, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1A73E8),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Déjà un compte ? Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
