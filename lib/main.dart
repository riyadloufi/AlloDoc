// lib/main.dart
import 'package:allo_doc/screens/doctor/home_doctor.dart';
import 'package:allo_doc/screens/login_screen.dart';
import 'package:allo_doc/screens/patient/home_patient.dart';
import 'package:allo_doc/screens/profile_screen.dart';
import 'package:allo_doc/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase initialisé avec succès");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlloDoc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Premium Royal Blue
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF10B981), // Premium Emerald Green
          background: const Color(0xFFF8FAFC), // Ultra-clean background
          surface: Colors.white,
          error: const Color(0xFFEF4444),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        
        // Premium Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.5),
          bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),

        // Modern App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),

        // Beautiful, Uniform Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 54),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Beautiful Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            minimumSize: const Size(double.infinity, 54),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Stunning unified InputDecoration Theme (Strips out 100s of lines of redundant UI code!)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIconColor: const Color(0xFF64748B),
          suffixIconColor: const Color(0xFF64748B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home_patient': (context) => const HomePatient(),
        '/home_doctor': (context) => const HomeDoctor(),
      },
      onGenerateRoute: (settings) {
        // Fallback pour les routes non définies
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}
