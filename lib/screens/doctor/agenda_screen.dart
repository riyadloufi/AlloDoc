import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appointment_card.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  final AppointmentService _service = AppointmentService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A73E8),
            child: Column(
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getWeekday(_selectedDate),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _service.getDoctorAppointments(doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                final appointments = snapshot.data ?? [];
                final filtered =
                    appointments
                        .where(
                          (app) =>
                              app.date.year == _selectedDate.year &&
                              app.date.month == _selectedDate.month &&
                              app.date.day == _selectedDate.day,
                        )
                        .toList()
                      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
                if (filtered.isEmpty)
                  return const Center(child: Text('Aucun rendez-vous ce jour'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => AppointmentCard(
                    appointment: filtered[index],
                    isDoctorView: true,
                    onCancel: () async {
                      await _service.cancelAppointment(filtered[index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('RDV annulé')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) => [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ][date.weekday - 1];
}
