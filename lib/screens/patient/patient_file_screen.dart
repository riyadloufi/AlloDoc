// lib/screens/doctor/patient_file_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';

class PatientFileScreen extends StatefulWidget {
  final String patientId;
  const PatientFileScreen({super.key, required this.patientId});

  @override
  State<PatientFileScreen> createState() => _PatientFileScreenState();
}

class _PatientFileScreenState extends State<PatientFileScreen> {
  late Future<UserModel> _patientFuture;
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _patientFuture = _getPatient();
  }

  Future<UserModel> _getPatient() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .get();
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier patient')),
      body: FutureBuilder<UserModel>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Patient introuvable'));
          }
          final patient = snapshot.data!;
          return Column(
            children: [
              // En-tête patient
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF1A73E8),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${patient.firstName} ${patient.lastName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      patient.email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Historique des consultations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<AppointmentModel>>(
                  stream: _appointmentService.getPatientAppointments(
                    widget.patientId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final appointments = snapshot.data ?? [];
                    if (appointments.isEmpty) {
                      return const Center(
                        child: Text('Aucun rendez-vous passé avec ce patient'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final app = appointments[index];
                        final hasIllness = app.chronicIllness.isNotEmpty && app.chronicIllness != 'Aucune';
                        final hasNote = app.description.isNotEmpty;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(
                                Icons.event_available,
                                color: app.status == 'confirmed' ? Colors.green : Colors.red,
                                size: 30,
                              ),
                              title: Text(
                                '${app.date.day}/${app.date.month}/${app.date.year} à ${app.timeSlot}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Motif : ${app.reason} • Statut : ${app.status}'),
                                  if (hasIllness) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Maladie : ${app.chronicIllness}',
                                        style: const TextStyle(
                                          color: Color(0xFFE11D48),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (hasNote) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Note : ${app.description}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
