import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'agenda_screen.dart';
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
    setState(() => _doctorName = 'Dr. ${doc['firstName']} ${doc['lastName']}');
  }

  Future<void> _countTodayAppointments() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where(
          'date',
          isLessThan: Timestamp.fromDate(today.add(const Duration(days: 1))),
        )
        .get();
    setState(() => _todayAppointments = snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AlloDoc - $_doctorName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF1A73E8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bonjour $_doctorName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Vous avez $_todayAppointments RDV aujourd\'hui',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(Icons.calendar_today, 'Mon agenda', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgendaScreen()),
                  );
                }),
                _buildMenuCard(Icons.people, 'Mes patients', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientsListScreen(),
                    ),
                  );
                }),
                _buildMenuCard(Icons.description, 'Ordonnances', () {}),
                _buildMenuCard(Icons.settings, 'Paramètres', () {
                  Navigator.pushNamed(context, '/profile');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF1A73E8)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
