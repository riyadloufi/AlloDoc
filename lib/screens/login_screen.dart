import 'package:allo_doc/screens/doctor/home_doctor.dart';
import 'package:allo_doc/screens/patient/home_patient.dart';
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
    setState(() {
      _isLoading = false;
    });

    if (role == null) {
      setState(() {
        _errorMsg = 'Email ou mot de passe incorrect';
      });
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
    return Scaffold(
      appBar: AppBar(title: Text("Login page")),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'AlloDoc',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            if (_errorMsg.isNotEmpty)
              Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1A73E8),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'se connecter',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
