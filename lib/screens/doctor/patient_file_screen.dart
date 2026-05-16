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
  final AppointmentService _service = AppointmentService();

  @override
  void initState() {
    super.initState();
    _patientFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .get()
        .then((doc) => UserModel.fromMap(doc.data()!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier patient')),
      body: FutureBuilder<UserModel>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return const Center(child: Text('Patient introuvable'));
          final patient = snapshot.data!;
          return Column(
            children: [
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
                  stream: _service.getPatientAppointments(widget.patientId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final apps = snapshot.data ?? [];
                    if (apps.isEmpty) {
                      return const Center(
                        child: Text('Aucun rendez-vous passé'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: apps.length,
                      itemBuilder: (_, i) => Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.event_available,
                            color: apps[i].status == 'confirmed'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(
                            '${apps[i].date.day}/${apps[i].date.month}/${apps[i].date.year} à ${apps[i].timeSlot}',
                          ),
                          subtitle: Text('Motif : ${apps[i].reason}'),
                        ),
                      ),
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
