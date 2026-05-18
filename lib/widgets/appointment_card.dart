import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/user_model.dart';

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
      : ((appointment.status == 'cancelled' || appointment.status == 'refused') ? Colors.red : Colors.orange);

  String _getStatusText() {
    switch (appointment.status) {
      case 'confirmed':
        return 'Confirmé';
      case 'cancelled':
        return 'Annulé';
      case 'refused':
        return 'Refusé';
      case 'pending':
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onCancel != null && (appointment.status == 'pending' || appointment.status == 'confirmed')) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Annuler'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (isDoctorView)
              Text(
                'Patient : ${appointment.patientName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            if (!isDoctorView)
              Text(
                UserModel.cleanDoctorName(appointment.doctorName),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            if (appointment.chronicIllness.isNotEmpty && appointment.chronicIllness != 'Aucune') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.healing, size: 14, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Text(
                      'Maladie : ${appointment.chronicIllness}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE11D48),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (appointment.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Note : ${appointment.description}',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if ((appointment.status == 'cancelled' || appointment.status == 'refused') && appointment.cancelReason.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Text(
                  'Motif du refus/annulation : ${appointment.cancelReason}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              appointment.date.year == DateTime.now().year &&
                      appointment.date.day == DateTime.now().day
                  ? "Aujourd'hui"
                  : '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
