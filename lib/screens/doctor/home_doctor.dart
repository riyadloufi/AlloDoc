import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'agenda_screen.dart';
import 'doctor_prescriptions_screen.dart';
import 'patients_list_screen.dart';

class HomeDoctor extends StatefulWidget {
  const HomeDoctor({super.key});

  @override
  State<HomeDoctor> createState() => _HomeDoctorState();
}

class _HomeDoctorState extends State<HomeDoctor> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  String _doctorName = '';
  int _todayAppointments = 0;
  StreamSubscription? _todayAppointmentsSubscription;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _countTodayAppointments();
  }

  Future<void> _loadDoctorInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      setState(() => _doctorName = 'Dr. ${doc['firstName']} ${doc['lastName']}');
    }
  }

  void _countTodayAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    _todayAppointmentsSubscription?.cancel();
    _todayAppointmentsSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('date', isLessThan: Timestamp.fromDate(tomorrow))
        .snapshots()
        .listen((snapshot) {
      final activeAppointments = snapshot.docs.where((doc) {
        final status = doc.data()['status'] ?? 'pending';
        return status != 'cancelled' && status != 'refused';
      }).toList();

      if (mounted) {
        setState(() => _todayAppointments = activeAppointments.length);
      }
    });
  }

  @override
  void dispose() {
    _todayAppointmentsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Espace Praticien',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 20),
              tooltip: 'Mon Profil',
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              tooltip: 'Se déconnecter',
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Welcome Gradient Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.healing,
                      size: 150,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _doctorName.isNotEmpty ? 'Bonjour $_doctorName' : 'Bonjour Docteur',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Heureux de vous revoir aujourd\'hui.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_todayAppointments RDV aujourd\'hui',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Raccourcis & Gestion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Modern Grid Menu Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard(
                  Icons.calendar_today,
                  'Mon agenda',
                  'Gérer vos rendez-vous',
                  const Color(0xFFE8F0FE),
                  const Color(0xFF1A73E8),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AgendaScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  Icons.people,
                  'Mes patients',
                  'Fiches & antécédents',
                  const Color(0xFFFFF1F2),
                  const Color(0xFFE11D48),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientsListScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  Icons.description,
                  'Ordonnances',
                  'Toutes les ordonnances',
                  const Color(0xFFF0FDF4),
                  const Color(0xFF15803D),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorPrescriptionsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  Icons.settings,
                  'Paramètres',
                  'Profil & informations',
                  const Color(0xFFF1F5F9),
                  const Color(0xFF475569),
                  () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    IconData icon,
    String label,
    String subtitle,
    Color bgIconColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
