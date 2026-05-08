import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isDoctorView;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isDoctorView = false,
    this.onCancel,
  });

  Color _getStatusColor() => appointment.status == 'confirmed'
      ? Colors.green
      : (appointment.status == 'cancelled' ? Colors.red : Colors.orange);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      appointment.status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onCancel != null && appointment.status != 'cancelled')
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Annuler'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDoctorView)
              Text(
                'Patient : ${appointment.patientName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (!isDoctorView)
              Text(
                'Dr. ${appointment.doctorName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${appointment.timeSlot} • ${appointment.date.day}/${appointment.date.month}',
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.medical_information,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(appointment.reason),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.date.year == DateTime.now().year &&
                      appointment.date.day == DateTime.now().day
                  ? "Aujourd'hui"
                  : '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
