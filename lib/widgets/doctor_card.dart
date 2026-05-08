import 'package:flutter/material.dart';

import '../models/user_model.dart';

class DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A73E8),
          radius: 28,
          child: Text(
            doctor.firstName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          'Dr. ${doctor.firstName} ${doctor.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Médecin généraliste'),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
          ),
          child: const Text(
            'Prendre RDV',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
