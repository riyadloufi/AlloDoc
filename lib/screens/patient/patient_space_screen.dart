import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

class PatientSpaceScreen extends StatefulWidget {
  const PatientSpaceScreen({super.key});

  @override
  State<PatientSpaceScreen> createState() => _PatientSpaceScreenState();
}

class _PatientSpaceScreenState extends State<PatientSpaceScreen> {
  final String patientId = FirebaseAuth.instance.currentUser!.uid;
  final AppointmentService _service = AppointmentService();
  int _selectedTab = 0; // 0: à venir, 1: passés

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon espace'), centerTitle: true),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [_buildTab('À venir', 0), _buildTab('Passés', 1)],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _service.getPatientAppointments(patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(child: Text('Aucun rendez-vous'));
                final now = DateTime.now();
                final filtered = _selectedTab == 0
                    ? snapshot.data!
                          .where(
                            (a) => a.date.isAfter(
                              now.subtract(const Duration(days: 1)),
                            ),
                          )
                          .toList()
                    : snapshot.data!
                          .where((a) => a.date.isBefore(now))
                          .toList();
                if (filtered.isEmpty)
                  return Center(
                    child: Text(
                      _selectedTab == 0
                          ? 'Aucun RDV à venir'
                          : 'Aucun RDV passé',
                    ),
                  );
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: app.status == 'confirmed'
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            app.status == 'confirmed'
                                ? Icons.check
                                : Icons.cancel,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Dr. ${app.doctorName}'),
                        subtitle: Text(
                          '${app.date.day}/${app.date.month}/${app.date.year} à ${app.timeSlot}',
                        ),
                        trailing:
                            (app.status == 'confirmed' &&
                                app.date.isAfter(DateTime.now()))
                            ? ElevatedButton(
                                onPressed: () async {
                                  await _service.cancelAppointment(app.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('RDV annulé'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedTab == index
                ? const Color(0xFF1A73E8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTab == index ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
